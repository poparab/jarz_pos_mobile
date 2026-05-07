import 'dart:convert';
import 'dart:io';

void main(List<String> args) {
  final options = _parseArgs(args);

  if (options.containsKey('help')) {
    stdout.writeln(_usage);
    return;
  }

  final repoRoot = _repoRoot();
  final channel = _normalizeChannel(_requiredOption(options, 'channel'));
  final versionInfo = _readPubspecVersion(repoRoot);
  final sourceSha = _optionOrGit(
    options,
    'sha',
    repoRoot,
    ['rev-parse', 'HEAD'],
  );
  final sourceBranch = _resolveBranch(options, repoRoot);
  final actor = _optionOrEnv(options, 'actor', 'GITHUB_ACTOR', fallback: 'local');
  final event = _optionOrEnv(options, 'event', 'GITHUB_EVENT_NAME', fallback: 'local');
  final runId = _optionOrEnv(options, 'run-id', 'GITHUB_RUN_ID');
  final runNumber = _optionOrEnv(options, 'run-number', 'GITHUB_RUN_NUMBER');
  final runAttempt = _optionOrEnv(options, 'run-attempt', 'GITHUB_RUN_ATTEMPT');
  final releaseNotesInput = options['release-notes'];
  final generatedAtUtc = DateTime.now().toUtc().toIso8601String();
  final shortSha = sourceSha.substring(0, 7);
  final buildNumber = _resolveBuildNumber(repoRoot, sourceSha, versionInfo.buildNumber);
  final buildNumberSource = _resolveBuildNumberSource(repoRoot, sourceSha, versionInfo.buildNumber);
  final environment = channel == 'staging' ? 'staging' : 'prod';
  final version = '${versionInfo.buildName}+$buildNumber';
  final artifactName = 'jarz-pos-$channel-v$version-$shortSha.apk';
  final artifactUploadName =
      '$channel-release-v${versionInfo.buildName}-b$buildNumber-${_attemptLabel(runAttempt)}';
  final metadataArtifactName =
      '$channel-release-metadata-v${versionInfo.buildName}-b$buildNumber-${_attemptLabel(runAttempt)}';
  final releaseId = '$channel-v$version-$shortSha';

  final metadata = <String, Object?>{
    'channel': channel,
    'environment': environment,
    'release_id': releaseId,
    'version': version,
    'build_name': versionInfo.buildName,
    'build_number': buildNumber,
    'artifact_name': artifactName,
    'artifact_upload_name': artifactUploadName,
    'metadata_artifact_name': metadataArtifactName,
    'generated_at_utc': generatedAtUtc,
    'version_policy': <String, Object?>{
      'build_name_source': 'pubspec.yaml version field before +',
      'build_number_source': buildNumberSource,
    },
    'source': <String, Object?>{
      'branch': sourceBranch,
      'sha': sourceSha,
      'short_sha': shortSha,
      'event': event,
      'actor': actor,
    },
    'ci': <String, Object?>{
      'run_id': runId,
      'run_number': runNumber,
      'run_attempt': runAttempt,
    },
  };

  final releaseNotes = _buildReleaseNotes(
    metadata: metadata,
    customNotes: releaseNotesInput,
  );

  final releaseNotesFile = options['release-notes-file'];
  if (releaseNotesFile != null && releaseNotesFile.isNotEmpty) {
    File(releaseNotesFile)
      ..createSync(recursive: true)
      ..writeAsStringSync('$releaseNotes\n');
  }

  final manifestFile = options['manifest-file'];
  if (manifestFile != null && manifestFile.isNotEmpty) {
    File(manifestFile)
      ..createSync(recursive: true)
      ..writeAsStringSync('${const JsonEncoder.withIndent('  ').convert(metadata)}\n');
  }

  final format = options['format'] ?? 'env';
  switch (format) {
    case 'env':
      _printEnv(
        buildName: versionInfo.buildName,
        buildNumber: buildNumber,
        version: version,
        artifactName: artifactName,
        artifactUploadName: artifactUploadName,
        metadataArtifactName: metadataArtifactName,
        releaseId: releaseId,
        shortSha: shortSha,
        generatedAtUtc: generatedAtUtc,
      );
    case 'json':
      stdout.writeln(const JsonEncoder.withIndent('  ').convert(metadata));
    default:
      stderr.writeln('Unsupported format: $format');
      stderr.writeln(_usage);
      exitCode = 1;
  }
}

const _usage = '''Usage: dart run tool/release_metadata.dart --channel <staging|production> [options]

Options:
  --channel <value>             Required release channel.
  --branch <value>              Source branch name.
  --sha <value>                 Source commit SHA.
  --event <value>               Trigger event name.
  --actor <value>               Triggering actor.
  --run-id <value>              CI run id.
  --run-number <value>          CI run number.
  --run-attempt <value>         CI run attempt.
  --release-notes <value>       Optional custom release notes text.
  --release-notes-file <path>   Optional path for generated release notes.
  --manifest-file <path>        Optional path for generated metadata JSON.
  --format <env|json>           Output format. Defaults to env.
  --help                        Print this message.
''';

Map<String, String> _parseArgs(List<String> args) {
  final options = <String, String>{};
  for (var index = 0; index < args.length; index++) {
    final arg = args[index];
    if (!arg.startsWith('--')) {
      throw FormatException('Unexpected argument: $arg');
    }
    final key = arg.substring(2);
    if (key == 'help') {
      options[key] = 'true';
      continue;
    }
    if (index + 1 >= args.length) {
      throw FormatException('Missing value for argument: $arg');
    }
    options[key] = args[++index];
  }
  return options;
}

Directory _repoRoot() {
  final scriptFile = File.fromUri(Platform.script);
  return scriptFile.parent.parent;
}

String _requiredOption(Map<String, String> options, String key) {
  final value = options[key];
  if (value == null || value.isEmpty) {
    throw FormatException('Missing required option: --$key');
  }
  return value;
}

String _normalizeChannel(String input) {
  switch (input.toLowerCase()) {
    case 'staging':
      return 'staging';
    case 'production':
    case 'prod':
      return 'production';
    default:
      throw FormatException('Unsupported channel: $input');
  }
}

_PubspecVersion _readPubspecVersion(Directory repoRoot) {
  final pubspec = File('${repoRoot.path}${Platform.pathSeparator}pubspec.yaml');
  final match = RegExp(r'^version:\s*([^\s+]+)(?:\+(\d+))?\s*$', multiLine: true)
      .firstMatch(pubspec.readAsStringSync());
  if (match == null) {
    throw StateError('Unable to read version from pubspec.yaml');
  }
  return _PubspecVersion(
    buildName: match.group(1)!,
    buildNumber: match.group(2),
  );
}

String _resolveBranch(Map<String, String> options, Directory repoRoot) {
  final branch = options['branch'];
  if (branch != null && branch.isNotEmpty) {
    return branch;
  }

  final currentBranch = _runGit(
    repoRoot,
    ['branch', '--show-current'],
    allowFailure: true,
  );
  if (currentBranch.isNotEmpty) {
    return currentBranch;
  }

  final fallback = _runGit(repoRoot, ['rev-parse', '--abbrev-ref', 'HEAD']);
  return fallback == 'HEAD' ? 'detached' : fallback;
}

String _optionOrGit(
  Map<String, String> options,
  String key,
  Directory repoRoot,
  List<String> command,
) {
  final value = options[key];
  if (value != null && value.isNotEmpty) {
    return value;
  }
  return _runGit(repoRoot, command);
}

String? _optionOrEnv(
  Map<String, String> options,
  String key,
  String envKey, {
  String? fallback,
}) {
  final option = options[key];
  if (option != null && option.isNotEmpty) {
    return option;
  }
  final env = Platform.environment[envKey];
  if (env != null && env.isNotEmpty) {
    return env;
  }
  return fallback;
}

String _resolveBuildNumber(Directory repoRoot, String sourceSha, String? fallback) {
  final gitCount = _runGit(
    repoRoot,
    ['rev-list', '--count', '--first-parent', sourceSha],
    allowFailure: true,
  );
  if (_isPositiveInteger(gitCount)) {
    return gitCount;
  }
  if (_isPositiveInteger(fallback)) {
    return fallback!;
  }
  throw StateError('Unable to resolve a numeric build number.');
}

String _resolveBuildNumberSource(Directory repoRoot, String sourceSha, String? fallback) {
  final gitCount = _runGit(
    repoRoot,
    ['rev-list', '--count', '--first-parent', sourceSha],
    allowFailure: true,
  );
  if (_isPositiveInteger(gitCount)) {
    return 'git rev-list --count --first-parent $sourceSha';
  }
  if (_isPositiveInteger(fallback)) {
    return 'pubspec.yaml build number fallback';
  }
  throw StateError('Unable to resolve build number source.');
}

bool _isPositiveInteger(String? value) {
  return value != null && RegExp(r'^[1-9]\d*$').hasMatch(value);
}

String _attemptLabel(String? runAttempt) {
  if (_isPositiveInteger(runAttempt)) {
    return 'attempt$runAttempt';
  }
  return 'local';
}

String _runGit(
  Directory repoRoot,
  List<String> args, {
  bool allowFailure = false,
}) {
  final result = Process.runSync(
    'git',
    args,
    workingDirectory: repoRoot.path,
    runInShell: true,
  );
  if (result.exitCode != 0) {
    if (allowFailure) {
      return '';
    }
    throw ProcessException('git', args, result.stderr.toString(), result.exitCode);
  }
  return result.stdout.toString().trim();
}

String _buildReleaseNotes({
  required Map<String, Object?> metadata,
  String? customNotes,
}) {
  final source = metadata['source']! as Map<String, Object?>;
  final ci = metadata['ci']! as Map<String, Object?>;
  final buffer = StringBuffer()
    ..writeln('Release ID: ${metadata['release_id']}')
    ..writeln('Channel: ${metadata['channel']}')
    ..writeln('Environment: ${metadata['environment']}')
    ..writeln('Version: ${metadata['version']}')
    ..writeln('Source branch: ${source['branch']}')
    ..writeln('Source commit: ${source['short_sha']}')
    ..writeln('Triggered by: ${source['event']} (${source['actor']})');

  if (ci['run_id'] != null) {
    buffer.writeln('GitHub run id: ${ci['run_id']}');
  }
  if (ci['run_number'] != null) {
    buffer.writeln('GitHub run number: ${ci['run_number']}');
  }
  if (ci['run_attempt'] != null) {
    buffer.writeln('GitHub run attempt: ${ci['run_attempt']}');
  }

  buffer.writeln('Generated at (UTC): ${metadata['generated_at_utc']}');

  if (customNotes != null && customNotes.trim().isNotEmpty) {
    buffer
      ..writeln()
      ..writeln(customNotes.trim());
  }

  return buffer.toString().trimRight();
}

void _printEnv({
  required String buildName,
  required String buildNumber,
  required String version,
  required String artifactName,
  required String artifactUploadName,
  required String metadataArtifactName,
  required String releaseId,
  required String shortSha,
  required String generatedAtUtc,
}) {
  stdout.writeln('BUILD_NAME=$buildName');
  stdout.writeln('BUILD_NUMBER=$buildNumber');
  stdout.writeln('VERSION=$version');
  stdout.writeln('ARTIFACT_NAME=$artifactName');
  stdout.writeln('ARTIFACT_UPLOAD_NAME=$artifactUploadName');
  stdout.writeln('METADATA_ARTIFACT_NAME=$metadataArtifactName');
  stdout.writeln('RELEASE_ID=$releaseId');
  stdout.writeln('SHORT_SHA=$shortSha');
  stdout.writeln('GENERATED_AT_UTC=$generatedAtUtc');
}

final class _PubspecVersion {
  const _PubspecVersion({required this.buildName, required this.buildNumber});

  final String buildName;
  final String? buildNumber;
}