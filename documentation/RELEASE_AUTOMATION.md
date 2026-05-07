# Release Automation

## What Is Tracked

- `scripts/deploy_backend.ps1`: remote Frappe backend deploy entrypoint.
- `scripts/deploy_web.ps1`: smart Flutter web deploy entrypoint for `/home/ubuntu/pos-web`.
- `scripts/watch_firebase_distribution.ps1`: GitHub Actions watcher and production trigger for Firebase App Distribution.
- `scripts/release_router.ps1`: safe orchestration entrypoint for staging and production release flows.
- `.vscode/tasks.json`: tracked VS Code tasks for plan and release execution when the `jarz_pos` repo is opened directly.

## Safety Rules

- The smart router refuses to execute when local repos are dirty unless `-AllowDirtyWorkingTree` is passed.
- Staging Firebase waits only for runs that match the current `origin/main` head commit.
- If no staging Firebase run appears within the grace window, the watcher exits successfully with a skip instead of hanging.
- Backend deploy planning compares the server's current app commits to the remote branch heads before it pulls or restarts anything.
- Web deploy planning compares the deployed web release metadata to the local repo head and skips deploy when no web-impacting paths changed since the last deployed web commit.
- Production Firebase distribution remains opt-in through `-IncludeFirebase`.

## Typical Commands

```powershell
Set-Location c:\ERPNext\jarz_pos_mobile\jarz_pos

# Safe pre-release plan
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\release_router.ps1 -Environment staging -PlanOnly

# Smart staging release
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\release_router.ps1 -Environment staging

# Smart production backend-only release
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\release_router.ps1 -Environment production

# Smart production release with Firebase distribution
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\release_router.ps1 -Environment production -IncludeFirebase

# Web-only plan
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\deploy_web.ps1 -Environment staging -PlanOnly
```

## What Gets Skipped

- Tooling-only or documentation-only pushes no longer trigger staging Firebase distribution because the workflow now has runtime path filters.
- Backend deploy skips reinstall, migrate, cache clear, and restart when the target server is already on the current backend app heads.
- Web deploy skips when the deployed web commit already matches the local repo head, or when the commit delta since the last deployed web commit has no web-impacting paths.
- Staging router skips Firebase waiting when the current commit did not create a matching Firebase workflow run.