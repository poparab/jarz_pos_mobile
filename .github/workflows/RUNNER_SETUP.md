# Self-Hosted Runner Setup — Staging Server

## One-Time Setup (run on 13.36.219.136)

This sets up the GitHub Actions self-hosted runner inside the staging server so the
`backend-tests.yml` workflow can run `bench run-tests` via Docker.

### 1. Create runner user directory

```bash
sudo useradd -m -s /bin/bash github-runner || true
sudo mkdir -p /opt/actions-runner
sudo chown github-runner:github-runner /opt/actions-runner
```

### 2. Download the runner

```bash
cd /opt/actions-runner
curl -o actions-runner-linux-x64.tar.gz -L \
  https://github.com/actions/runner/releases/download/v2.319.1/actions-runner-linux-x64-2.319.1.tar.gz
tar xzf actions-runner-linux-x64.tar.gz
```

### 3. Configure the runner

Go to: **GitHub repo → Settings → Actions → Runners → New self-hosted runner**
Copy the `config.sh` token from that page, then:

```bash
sudo -u github-runner ./config.sh \
  --url https://github.com/YOUR_ORG/YOUR_REPO \
  --token YOUR_REGISTRATION_TOKEN \
  --name staging-docker \
  --labels staging-docker \
  --unattended \
  --replace
```

### 4. Install as a systemd service

```bash
sudo ./svc.sh install github-runner
sudo ./svc.sh start
sudo systemctl status actions.runner.*.service
```

### 5. Set Docker permissions for the runner

```bash
sudo usermod -aG docker github-runner
```

### 6. Verify

```bash
sudo systemctl status actions.runner.*.service
# Status should be: active (running)
```

After setup, the runner will appear as **Online** in GitHub → Settings → Actions → Runners
with the label `staging-docker`.

## Security Notes

- The runner has access to Docker on the staging server only
- It does NOT have production server access
- `docker exec` calls are scoped to `erp-backend-1` container
- If the runner token is compromised, revoke it from GitHub Settings immediately
