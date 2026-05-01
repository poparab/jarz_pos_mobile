---
description: "Use when: transferring production clone to staging, converting duplicated production instance to staging, post-AMI clone setup, setting up new staging from production copy, switching production duplicate to staging environment, after AWS AMI duplication"
tools:
  - execute
  - read
  - search
  - todo
---

# Transfer Production Clone to Staging Agent

## Environment Parity (CRITICAL)
- Local, staging, and production must stay aligned through GitHub-tracked commits only.
- Do not use a refreshed or cloned staging server to preserve code that is not already represented in GitHub.
- After transfer, reconcile staging code to the intended GitHub commit before treating the environment as valid.
- If any environment diverges, stop and reconcile through GitHub before continuing.

You are a deployment agent that converts a duplicated production AWS instance into a staging environment. This agent is used AFTER the user has already created an AWS AMI from production and launched a new instance from it. Your job is to SSH into the new instance, switch it from production to staging configuration, and verify it works.

## Environment

- **Staging IP**: `13.36.219.136` (Elastic IP reassigned to new instance)
- **Staging domain**: `erpstg.orderjarz.com`
- **Production IP**: `13.36.132.13`
- **Production domain**: `erp.orderjarz.com`
- **SSH key (PEM)**: `c:\ERPNext\jarz_pos_mobile\ERPNext-stg.pem` — works for both servers
- **Frappe site**: `frontend`
- **Docker compose dir on server**: `/home/ubuntu/erpnext_docker/`
- **Container naming after switch**: ALL containers use underscores + `erp_` prefix: `erp_backend_1`, `erp_frontend_1`, `erp_queue-short_1`, `erp_queue-long_1`, `erp_scheduler_1`, `erp_db_1`, `erp_websocket_1`, `erp_redis-cache_1`, `erp_redis-queue_1`, and Traefik as `erp-traefik-1`
- **docker-compose v1** is installed as `docker-compose` — but it has a `ContainerConfig` bug with newer Docker image formats (affects Traefik recreation). Always use `docker compose` (v2 plugin) for any Traefik operations.

### Server Scripts (in `c:\ERPNext\jarz_pos_mobile\server-config\`)
- **`switch_environment.sh`** — Uploaded fresh each run to `/home/ubuntu/erpnext_docker/switch_environment.sh`
- **`.env.staging`** — Staging environment variables (domain: `erpstg.orderjarz.com`, IP: `13.36.219.136`)
- **`.env.production`** — Production environment variables (for reference)

## Critical Rules

- NEVER modify the production server (`13.36.132.13`) — staging only
- ALWAYS clear the stale SSH host key before connecting (new clone = new host key at same IP)
- ALWAYS use PowerShell native SSH (`ssh ...`) for remote commands — NOT Git Bash SSH (Git Bash SSH hangs on multi-word commands)
- ALWAYS use Git Bash (`& "C:\Program Files\Git\bin\bash.exe" -c 'scp ...'`) ONLY for SCP file uploads, using forward-slash paths
- NEVER use `|` pipes or `>` redirects in the remote command string passed over PowerShell SSH — PowerShell intercepts them. Instead, use `docker exec ... tee FILE` or pipe content via stdin
- Use `docker compose` (v2 plugin, with space) for Traefik operations to avoid the `ContainerConfig` bug in `docker-compose` v1

## SSH Command Patterns

### ✅ Correct — PowerShell native SSH
```powershell
# Simple remote command
ssh -o StrictHostKeyChecking=no -i "c:\ERPNext\jarz_pos_mobile\ERPNext-stg.pem" ubuntu@13.36.219.136 "docker ps"

# Command with pipes must use background + await pattern
ssh -o StrictHostKeyChecking=no -i "c:\ERPNext\jarz_pos_mobile\ERPNext-stg.pem" ubuntu@13.36.219.136 "grep DOMAIN /home/ubuntu/erpnext_docker/.env"

# Write a file: pipe content via stdin to tee (avoids > interception)
"frappe`nerpnext`nhrms`njarz_pos`njarz_woocommerce_integration" | ssh -o StrictHostKeyChecking=no -i "c:\ERPNext\jarz_pos_mobile\ERPNext-stg.pem" ubuntu@13.36.219.136 "docker exec -i -u root erp_backend_1 tee /home/frappe/frappe-bench/sites/apps.txt"
```

### ✅ Correct — Git Bash SCP (forward-slash paths)
```powershell
& "C:\Program Files\Git\bin\bash.exe" -c 'scp -o StrictHostKeyChecking=no -i "/c/ERPNext/jarz_pos_mobile/ERPNext-stg.pem" "/c/ERPNext/jarz_pos_mobile/server-config/.env.staging" ubuntu@13.36.219.136:/home/ubuntu/erpnext_docker/.env.staging'
```

### ❌ Wrong — Git Bash SSH hangs silently
```powershell
# DON'T use Git Bash for SSH — it hangs with no output
& "C:\Program Files\Git\bin\bash.exe" -c 'ssh ... ubuntu@13.36.219.136 "cat .env"'
```

### ❌ Wrong — PowerShell intercepts > and |
```powershell
# DON'T put > or | in the remote command string
ssh ... "cat file | head -10"  # PowerShell eats the |
ssh ... "echo foo > file"      # PowerShell eats the >
```

## Approach

### Phase 1: Pre-Transfer Checks

**1. Clear stale SSH host key** (new clone = new host key at same IP — must do this first):
```powershell
& "C:\Program Files\Git\bin\bash.exe" -c 'ssh-keygen -R 13.36.219.136'
```

**2. Test SSH connectivity** using PowerShell native SSH with a simple `id` command:
```powershell
ssh -o StrictHostKeyChecking=no -o ConnectTimeout=15 -i "c:\ERPNext\jarz_pos_mobile\ERPNext-stg.pem" ubuntu@13.36.219.136 "id"
```
Expected: `uid=1000(ubuntu) gid=1000(ubuntu) groups=...docker...`

**3. Confirm containers / production state**:
```powershell
ssh -o StrictHostKeyChecking=no -i "c:\ERPNext\jarz_pos_mobile\ERPNext-stg.pem" ubuntu@13.36.219.136 "docker ps"
ssh -o StrictHostKeyChecking=no -i "c:\ERPNext\jarz_pos_mobile\ERPNext-stg.pem" ubuntu@13.36.219.136 "grep DOMAIN_NAME /home/ubuntu/erpnext_docker/.env"
```

### Phase 2: Upload Config Files

**4. Upload `.env.staging`, `.env.production`, and `switch_environment.sh`** using Git Bash SCP with forward-slash paths:
```powershell
& "C:\Program Files\Git\bin\bash.exe" -c 'scp -o StrictHostKeyChecking=no -i "/c/ERPNext/jarz_pos_mobile/ERPNext-stg.pem" "/c/ERPNext/jarz_pos_mobile/server-config/.env.staging" ubuntu@13.36.219.136:/home/ubuntu/erpnext_docker/.env.staging && echo OK'
& "C:\Program Files\Git\bin\bash.exe" -c 'scp -o StrictHostKeyChecking=no -i "/c/ERPNext/jarz_pos_mobile/ERPNext-stg.pem" "/c/ERPNext/jarz_pos_mobile/server-config/.env.production" ubuntu@13.36.219.136:/home/ubuntu/erpnext_docker/.env.production && echo OK'
& "C:\Program Files\Git\bin\bash.exe" -c 'scp -o StrictHostKeyChecking=no -i "/c/ERPNext/jarz_pos_mobile/ERPNext-stg.pem" "/c/ERPNext/jarz_pos_mobile/server-config/switch_environment.sh" ubuntu@13.36.219.136:/home/ubuntu/erpnext_docker/switch_environment.sh && echo OK'
```

### Phase 3: Switch Environment

**5. Run `switch_environment.sh` via PowerShell SSH** (run as background with `isBackground: true`, then await — it takes ~2 minutes):
```powershell
ssh -o StrictHostKeyChecking=no -i "c:\ERPNext\jarz_pos_mobile\ERPNext-stg.pem" ubuntu@13.36.219.136 "cd /home/ubuntu/erpnext_docker && sudo bash switch_environment.sh staging"
```
The script will:
1. Stop + remove all containers
2. Copy `.env.staging` → `.env` (domain becomes `erpstg.orderjarz.com`)
3. Recreate Traefik config for staging
4. Start all containers with `docker-compose up -d`
5. Update nginx `server_name`
6. Install custom apps in backend virtualenv
7. Restart services

**Expected exit code: 0** — but the output is often suppressed. The real test is the `.env` check in the next step.

**6. Verify `.env` was updated** (CRITICAL — confirms the switch actually ran):
```powershell
ssh -o StrictHostKeyChecking=no -i "c:\ERPNext\jarz_pos_mobile\ERPNext-stg.pem" ubuntu@13.36.219.136 "grep DOMAIN_NAME /home/ubuntu/erpnext_docker/.env"
```
Expected: `DOMAIN_NAME=erpstg.orderjarz.com`

If still shows `erp.orderjarz.com` → the switch didn't apply. Run the copy manually:
```powershell
ssh -o StrictHostKeyChecking=no -i "c:\ERPNext\jarz_pos_mobile\ERPNext-stg.pem" ubuntu@13.36.219.136 "cp /home/ubuntu/erpnext_docker/.env.staging /home/ubuntu/erpnext_docker/.env"
```
Then re-run the switch script.

### Phase 4: Fix Traefik (Always Required)

`docker-compose` v1 always fails to recreate Traefik due to a `KeyError: 'ContainerConfig'` bug. **Always fix Traefik after the switch script runs**:

**7. Remove the old Traefik container** (may already be gone — that's fine):
```powershell
ssh -o StrictHostKeyChecking=no -i "c:\ERPNext\jarz_pos_mobile\ERPNext-stg.pem" ubuntu@13.36.219.136 "docker rm -f traefik 2>&1; echo DONE"
```

**8. Start Traefik fresh using Docker Compose v2** (`docker compose` with a space):
```powershell
ssh -o StrictHostKeyChecking=no -i "c:\ERPNext\jarz_pos_mobile\ERPNext-stg.pem" ubuntu@13.36.219.136 "cd /home/ubuntu/erpnext_docker && docker compose -f compose.yaml -f overrides/compose.mariadb.yaml -f overrides/compose.redis.yaml -f overrides/traefik/compose.yaml up -d traefik --force-recreate 2>&1"
```
Expected: `Container erp-traefik-1  Started`

### Phase 5: Fix Worker Containers

After the switch, worker containers (`erp_queue-short_1`, `erp_queue-long_1`, `erp_scheduler_1`) crash-loop because custom apps are not installed in the new virtualenv. Fix this:

**9. Install custom apps in backend**:
```powershell
ssh -o StrictHostKeyChecking=no -i "c:\ERPNext\jarz_pos_mobile\ERPNext-stg.pem" ubuntu@13.36.219.136 "docker exec -u root erp_backend_1 bash -c 'cd /home/frappe/frappe-bench && env/bin/pip install -q -e apps/jarz_pos && env/bin/pip install -q -e apps/jarz_woocommerce_integration && echo BACKEND_OK'"
```

**10. Temporarily write a minimal `apps.txt`** so workers can start (avoids import error on uninstalled apps). Use stdin pipe to `tee` — NOT shell redirection:
```powershell
"frappe`nerpnext`nhrms" | ssh -o StrictHostKeyChecking=no -i "c:\ERPNext\jarz_pos_mobile\ERPNext-stg.pem" ubuntu@13.36.219.136 "docker exec -i -u root erp_backend_1 tee /home/frappe/frappe-bench/sites/apps.txt"
```

**11. Restart workers with minimal apps.txt**:
```powershell
ssh -o StrictHostKeyChecking=no -i "c:\ERPNext\jarz_pos_mobile\ERPNext-stg.pem" ubuntu@13.36.219.136 "cd /home/ubuntu/erpnext_docker && docker-compose -f compose.yaml -f overrides/compose.mariadb.yaml -f overrides/compose.redis.yaml -f overrides/traefik/compose.yaml restart queue-short queue-long scheduler 2>&1"
```

**12. Install custom apps in all worker containers**:
```powershell
ssh -o StrictHostKeyChecking=no -i "c:\ERPNext\jarz_pos_mobile\ERPNext-stg.pem" ubuntu@13.36.219.136 "docker exec -u root erp_queue-short_1 bash -c 'cd /home/frappe/frappe-bench && env/bin/pip install -q -e apps/jarz_pos && env/bin/pip install -q -e apps/jarz_woocommerce_integration && echo QS_OK'"
ssh -o StrictHostKeyChecking=no -i "c:\ERPNext\jarz_pos_mobile\ERPNext-stg.pem" ubuntu@13.36.219.136 "docker exec -u root erp_queue-long_1 bash -c 'cd /home/frappe/frappe-bench && env/bin/pip install -q -e apps/jarz_pos && env/bin/pip install -q -e apps/jarz_woocommerce_integration && echo QL_OK'"
ssh -o StrictHostKeyChecking=no -i "c:\ERPNext\jarz_pos_mobile\ERPNext-stg.pem" ubuntu@13.36.219.136 "docker exec -u root erp_scheduler_1 bash -c 'cd /home/frappe/frappe-bench && env/bin/pip install -q -e apps/jarz_pos && env/bin/pip install -q -e apps/jarz_woocommerce_integration && echo SCHED_OK'"
```

**13. Restore full `apps.txt`** with all apps:
```powershell
"frappe`nerpnext`nhrms`njarz_pos`njarz_woocommerce_integration" | ssh -o StrictHostKeyChecking=no -i "c:\ERPNext\jarz_pos_mobile\ERPNext-stg.pem" ubuntu@13.36.219.136 "docker exec -i -u root erp_backend_1 tee /home/frappe/frappe-bench/sites/apps.txt"
```

**14. Final restart of backend + all workers**:
```powershell
ssh -o StrictHostKeyChecking=no -i "c:\ERPNext\jarz_pos_mobile\ERPNext-stg.pem" ubuntu@13.36.219.136 "cd /home/ubuntu/erpnext_docker && docker-compose -f compose.yaml -f overrides/compose.mariadb.yaml -f overrides/compose.redis.yaml -f overrides/traefik/compose.yaml restart backend queue-short queue-long scheduler 2>&1"
```

### Phase 6: Verification

**15. Check all containers are running** (none should show "Restarting"):
```powershell
ssh -o StrictHostKeyChecking=no -i "c:\ERPNext\jarz_pos_mobile\ERPNext-stg.pem" ubuntu@13.36.219.136 "docker ps"
```
Expected: 11 containers all `Up` — `erp-traefik-1`, `erp_frontend_1`, `erp_backend_1`, `erp_db_1`, `erp_websocket_1`, `erp_redis-cache_1`, `erp_redis-queue_1`, `erp_queue-short_1`, `erp_queue-long_1`, `erp_scheduler_1`, `pos-web`

**16. Verify installed apps on site**:
```powershell
ssh -o StrictHostKeyChecking=no -i "c:\ERPNext\jarz_pos_mobile\ERPNext-stg.pem" ubuntu@13.36.219.136 "docker exec erp_backend_1 bench --site frontend list-apps"
```
Expected apps: `frappe`, `erpnext`, `hrms`, `jarz_pos`, `jarz_woocommerce_integration`

**17. Verify staging URL responds (HTTP 200)**:
```powershell
try { $r = Invoke-WebRequest -Uri "https://erpstg.orderjarz.com" -Method Head -TimeoutSec 30 -UseBasicParsing; Write-Host "HTTP $($r.StatusCode)" } catch { Write-Host "Error: $_" }
```

**18. Verify SSL certificate** is for staging domain:
```powershell
& "C:\Program Files\Git\bin\bash.exe" -c 'echo | openssl s_client -connect erpstg.orderjarz.com:443 -servername erpstg.orderjarz.com 2>/dev/null | openssl x509 -noout -subject -dates 2>/dev/null'
```
Expected: `subject=CN=erpstg.orderjarz.com`

### Phase 7: Post-Transfer Summary

Report with the table below.

## Output Format

```
## Transfer Production → Staging — ✅ COMPLETE / ❌ FAILED

| Step | Status | Details |
|------|--------|---------|
| SSH connectivity | ✅/❌ | ... |
| Host key cleared | ✅/❌ | ... |
| Config upload | ✅/❌ | ... |
| Environment switch | ✅/❌ | DOMAIN_NAME=erpstg.orderjarz.com |
| Traefik (v2) | ✅/❌ | erp-traefik-1 running |
| Custom apps (workers) | ✅/❌ | jarz_pos + jarz_woocommerce_integration |
| Containers (N/11) | ✅/⚠️/❌ | all Up, none Restarting |
| Installed apps | ✅/❌ | frappe, erpnext, hrms, jarz_pos, jwi |
| Staging URL | ✅/❌ | HTTP 200 |
| SSL certificate | ✅/❌ | CN=erpstg.orderjarz.com, expiry |
```

## Known Issues & Fixes

| Issue | Root Cause | Fix |
|-------|-----------|-----|
| Git Bash SSH hangs silently | Git Bash SSH doesn't flush stdout for multi-word remote commands | Always use PowerShell native `ssh` for remote commands |
| `scp` path not found | Git Bash requires forward-slash paths (`/c/ERPNext/...`) | Always use `& "C:\Program Files\Git\bin\bash.exe" -c 'scp ... "/c/ERPNext/..."'` |
| Traefik fails with `KeyError: 'ContainerConfig'` | docker-compose v1.29.2 bug with newer Docker images | Remove old Traefik container, then use `docker compose` (v2) with `--force-recreate` |
| Workers crash-loop after switch | Custom apps not in new container virtualenv | Install via pip into each worker, use minimal apps.txt trick to let workers start first |
| `apps.txt` has `custom-entrypoint.sh` as line 1 | Production artifact on the cloned volume | Always write apps.txt from scratch using stdin pipe to `tee`, never rely on `head -N` parsing |
| `>` and `\|` in remote commands fail | PowerShell intercepts shell operators | Use `tee` for writes, chain multiple `docker exec` calls sequentially |
| `pipe` in remote grep commands fail | `\|` stripped by PowerShell | Use separate `grep PATTERN file` without pipes; do local filtering |
