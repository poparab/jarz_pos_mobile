# Release Versioning Policy

## Source Of Truth

- Semantic version source: `pubspec.yaml` `version:` field before the `+`
- Build number source: `git rev-list --count --first-parent <commit>` for the exact commit being built
- Release channel source: the workflow job itself (`staging` and `production` on push to `main`; production can also be run manually from `main`)

This means the same commit produces the same app version on both channels:

- same `build_name`
- same `build_number`
- same `version`

Only the channel, Android release type, Firebase target for full APKs, and APK filename prefix differ.

## Hard Rules

1. Bump the semantic version only in `pubspec.yaml` and only through a git commit.
2. Do not override semantic version or build number from GitHub Actions.
3. Treat production as a release built from `main` using the same commit-derived versioning as staging.
4. Trigger production only from `main`.
5. Use the optional manual production `release_notes` input only for human notes, not for version control.
6. Decide `full_apk`, `shorebird_patch`, or `none` before any Android rollout.
7. `shorebird_patch` is allowed only for code-push-safe Dart changes after a Shorebird-enabled APK is already installed.

## Naming Policy

For every full APK release:

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

Every Android workflow run that performs a mobile release now produces:

- the versioned APK artifact for `full_apk` releases
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
3. Every push to `main` auto-classifies the staging Android release as `full_apk`, `shorebird_patch`, or `none`.
4. Production Android releases are manual from `main`; choose `full_apk` or `shorebird_patch` explicitly.
5. Validate staging artifacts or patches before any production Android rollout.

Because the build number comes from the commit history instead of the workflow run number, staging and production stay aligned for the same commit while still producing a new installable APK on every full release commit.

## Files That Enforce This Policy

- `.github/workflows/firebase-app-distribution.yml`
- `tool/release_metadata.dart`
- `scripts/classify_mobile_release.ps1`
- `scripts/shorebird_android.ps1`

## Operator Guidance

- If a rerun is needed for the same commit, the app version remains the same by design.
- The rerun is still distinguishable in GitHub by the artifact label `attempt<run_attempt>`.
- If you need a new installable build for testers, create a new commit on `main` or intentionally bump the semantic version in `pubspec.yaml`.
- If you only need a Dart-only fix and the Shorebird-enabled APK is already installed, prefer a Shorebird patch instead of a new APK.