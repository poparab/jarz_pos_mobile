# Release Automation

## What Is Tracked

- `scripts/deploy_backend.ps1`: remote Frappe backend deploy entrypoint.
- `scripts/deploy_web.ps1`: smart Flutter web deploy entrypoint for `/home/ubuntu/pos-web`.
- `scripts/classify_mobile_release.ps1`: classifies Android changes as `full_apk`, `shorebird_patch`, or `none`.
- `scripts/shorebird_android.ps1`: Shorebird Android release and patch wrapper.
- `scripts/watch_android_release.ps1`: GitHub Actions watcher and production trigger for Android release workflows.
- `scripts/release_router.ps1`: safe orchestration entrypoint for staging and production release flows.
- `.vscode/tasks.json`: tracked VS Code tasks for plan and release execution when the `jarz_pos` repo is opened directly.

## Safety Rules

- The smart router refuses to execute when local repos are dirty unless `-AllowDirtyWorkingTree` is passed.
- The smart router now reports `full_apk`, `shorebird_patch`, or `none` for Android changes before it starts release work.
- Staging Android release waits only for runs that match the current `origin/main` head commit.
- If no staging Android run appears within the grace window, the watcher exits successfully with a skip instead of hanging.
- Backend deploy planning compares the server's current app commits to the remote branch heads before it pulls or restarts anything.
- Web deploy planning compares the deployed web release metadata to the local repo head and skips deploy when no web-impacting paths changed since the last deployed web commit.
- Production Android release remains opt-in through `-IncludeFirebase`, and production patches must be dispatched explicitly.

## Typical Commands

```powershell
Set-Location c:\ERPNext\jarz_pos_mobile\jarz_pos

# Safe pre-release plan
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\release_router.ps1 -Environment staging -PlanOnly

# Smart staging release
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\release_router.ps1 -Environment staging

# Smart production backend-only release
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\release_router.ps1 -Environment production

# Smart production full APK release
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\release_router.ps1 -Environment production -IncludeFirebase

# Smart production Shorebird patch release
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\release_router.ps1 -Environment production -IncludeFirebase -MobileReleaseType shorebird_patch

# Web-only plan
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\deploy_web.ps1 -Environment staging -PlanOnly
```

## What Gets Skipped

- Tooling-only or documentation-only pushes no longer trigger staging Firebase distribution because the workflow now has runtime path filters.
- Android runtime changes are classified before release; Dart-only code-push-safe changes can use Shorebird patching once Shorebird bootstrap is complete.
- Backend deploy skips reinstall, migrate, cache clear, and restart when the target server is already on the current backend app heads.
- Web deploy skips when the deployed web commit already matches the local repo head, or when the commit delta since the last deployed web commit has no web-impacting paths.
- Staging router skips Android workflow waiting when the current commit did not create a matching Android release workflow run.