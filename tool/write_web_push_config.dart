import 'dart:convert';
import 'dart:io';

void main(List<String> args) {
  final arguments = _parseArgs(args);
  final envFilePath = arguments['env-file'];
  final outputFilePath = arguments['output-file'];

  if (envFilePath == null || outputFilePath == null) {
    stderr.writeln(
      'Usage: dart tool/write_web_push_config.dart --env-file <path> --output-file <path>',
    );
    exitCode = 64;
    return;
  }

  final envFile = File(envFilePath);
  if (!envFile.existsSync()) {
    stderr.writeln('Env file not found: $envFilePath');
    exitCode = 66;
    return;
  }

  final environment = _readEnvFile(envFile);
  final outputFile = File(outputFilePath);

  if (!_envBool(environment['WEB_PUSH_ENABLED'])) {
    if (outputFile.existsSync()) {
      outputFile.deleteSync();
    }
    stdout.writeln('[web_push_config] WEB_PUSH_ENABLED is false; skipping config generation.');
    return;
  }

  final requiredKeys = <String>[
    'FIREBASE_WEB_API_KEY',
    'FIREBASE_WEB_PROJECT_ID',
    'FIREBASE_WEB_MESSAGING_SENDER_ID',
    'FIREBASE_WEB_APP_ID',
  ];
  final missingKeys = requiredKeys.where((key) => (environment[key] ?? '').trim().isEmpty).toList(growable: false);
  if (missingKeys.isNotEmpty) {
    stderr.writeln(
      'WEB_PUSH_ENABLED is true but the following keys are missing: ${missingKeys.join(', ')}',
    );
    exitCode = 78;
    return;
  }

  final config = <String, String>{
    'apiKey': environment['FIREBASE_WEB_API_KEY']!.trim(),
    'projectId': environment['FIREBASE_WEB_PROJECT_ID']!.trim(),
    'messagingSenderId': environment['FIREBASE_WEB_MESSAGING_SENDER_ID']!.trim(),
    'appId': environment['FIREBASE_WEB_APP_ID']!.trim(),
  };

  for (final entry in <MapEntry<String, String>>[
    const MapEntry('authDomain', 'FIREBASE_WEB_AUTH_DOMAIN'),
    const MapEntry('storageBucket', 'FIREBASE_WEB_STORAGE_BUCKET'),
    const MapEntry('measurementId', 'FIREBASE_WEB_MEASUREMENT_ID'),
  ]) {
    final value = (environment[entry.value] ?? '').trim();
    if (value.isNotEmpty) {
      config[entry.key] = value;
    }
  }

  outputFile.parent.createSync(recursive: true);
  final content = StringBuffer()
    ..writeln('// Generated from ${envFile.path}. Do not edit manually.')
    ..writeln('self.JARZ_FIREBASE_WEB_CONFIG = ${const JsonEncoder.withIndent('  ').convert(config)};');
  outputFile.writeAsStringSync(content.toString());
  stdout.writeln('[web_push_config] Wrote ${outputFile.path}');
}

Map<String, String> _parseArgs(List<String> args) {
  final arguments = <String, String>{};
  for (var index = 0; index < args.length; index++) {
    final argument = args[index];
    if (!argument.startsWith('--')) {
      continue;
    }

    if (index + 1 >= args.length) {
      break;
    }

    arguments[argument.substring(2)] = args[index + 1];
    index++;
  }
  return arguments;
}

Map<String, String> _readEnvFile(File envFile) {
  final values = <String, String>{};
  for (final rawLine in envFile.readAsLinesSync()) {
    final line = rawLine.trim();
    if (line.isEmpty || line.startsWith('#')) {
      continue;
    }

    final separatorIndex = line.indexOf('=');
    if (separatorIndex <= 0) {
      continue;
    }

    final key = line.substring(0, separatorIndex).trim();
    final value = line.substring(separatorIndex + 1).trim();
    values[key] = value;
  }
  return values;
}

bool _envBool(String? value) {
  final normalized = (value ?? '').trim().toLowerCase();
  return normalized == '1' ||
      normalized == 'true' ||
      normalized == 'yes' ||
      normalized == 'on';
}