# Release Versioning Policy

## Source Of Truth

- Semantic version source: `pubspec.yaml` `version:` field before the `+`
- Build number source: `git rev-list --count --first-parent <commit>` for the exact commit being built
- Release channel source: the workflow job itself (`staging` on push to `main`, `production` on manual dispatch from `main`)

This means the same commit produces the same app version on both channels:

- same `build_name`
- same `build_number`
- same `version`

Only the channel, Firebase target, and APK filename prefix differ.

## Hard Rules

1. Bump the semantic version only in `pubspec.yaml` and only through a git commit.
2. Do not override semantic version or build number from GitHub Actions.
3. Treat production as a promotion of a commit already validated on staging.
4. Trigger production only from `main`.
5. Use the manual production `release_notes` input only for human notes, not for version control.

## Naming Policy

For every distributed APK:

- APK filename: `jarz-pos-<channel>-v<build_name>+<build_number>-<short_sha>.apk`
- Release id: `<channel>-v<build_name>+<build_number>-<short_sha>`
- GitHub artifact label: `<channel>-release-v<build_name>-b<build_number>-attempt<run_attempt>`
- Metadata artifact label: `<channel>-release-metadata-v<build_name>-b<build_number>-attempt<run_attempt>`

Examples:

- `jarz-pos-staging-v1.0.0+195-79c42a0.apk`
- `jarz-pos-production-v1.0.0+195-79c42a0.apk`
- `staging-release-v1.0.0-b195-attempt2`
- `production-release-metadata-v1.0.0-b195-attempt1`

## Tracking Policy

Every staging and production workflow run now produces:

- the versioned APK artifact
- a metadata artifact containing:
  - a JSON manifest
  - the exact release notes sent to Firebase App Distribution
- a GitHub job summary with:
  - release id
  - version
  - APK artifact label
  - metadata artifact label
  - commit short SHA
  - generation timestamp

This gives one clean audit trail per release without relying on Firebase naming alone.

## Promotion Flow

1. Update `pubspec.yaml` when you want a new semantic release line such as `1.0.0` to `1.1.0`.
2. Commit and push that change through GitHub.
3. The staging workflow on `main` builds and distributes the staging APK automatically.
4. Validate staging on the exact commit you want to promote.
5. Run the manual production workflow from that same `main` commit.
6. Add optional human release notes in the workflow input if needed.

Because the build number comes from the commit history instead of the workflow run number, staging and production stay aligned for the same commit.

## Files That Enforce This Policy

- `.github/workflows/firebase-app-distribution.yml`
- `tool/release_metadata.dart`

## Operator Guidance

- If a rerun is needed for the same commit, the app version remains the same by design.
- The rerun is still distinguishable in GitHub by the artifact label `attempt<run_attempt>`.
- If you need a new installable build for testers, create a new commit on `main` or intentionally bump the semantic version in `pubspec.yaml`.