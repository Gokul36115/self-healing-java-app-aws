# Errors faced & fixes

## 1. apt lock held by unattended-upgrade
- **Error:** `Could not get lock /var/lib/dpkg/lock-frontend. It is held by process 5781 (unattended-upgr)`
- **Cause:** Ubuntu's automatic security updates were running in the background.
- **Fix:** Found the process with `ps -ef | grep 5781`. Waited for it to finish instead of killing it (killing it can corrupt the dpkg database).

## 2. Port 8080 already in use
- **Error:** `Web server failed to start. Port 8080 was already in use.`
- **Cause:** Jenkins was already listening on 8080 on the VM.
- **Fix:** Confirmed with `ps -ef | grep 8080` / `ss -tlnp`. Ran the app locally on 8081 (`--server.port=8081`). In Docker the app keeps 8080 inside the container and is mapped with `-p 8081:8080`.

## 3. OutOfMemoryError: app broken but container still "healthy" (found via chaos test)
- **Symptom:** `/api/memory` returned HTTP 500, logs showed `java.lang.OutOfMemoryError: Java heap space`, but `docker ps` still showed `(healthy)` and RestartCount stayed 0.
- **Cause:** JVM default heap = 25% of container limit (`MaxHeapSize=134217728` ≈ 128 MB of 512 MB). Heap filled up long before the container limit, so the JVM stayed alive in a broken state. Docker's restart policy only reacts when the process exits.
- **Fix:** Added `-XX:+ExitOnOutOfMemoryError` to the Dockerfile ENTRYPOINT (image v2). JVM now exits with code 3 on OOM and `--restart unless-stopped` recovers it automatically.
- **Verified:** `docker events` showed `exitCode=3`, RestartCount 0 → 1, log line `Terminating due to java.lang.OutOfMemoryError`, container back to `(healthy)`.

## 4. Jenkins apt repo: NO_PUBKEY 7198F4B714ABFC68
- **Error:** `apt-get update` showed `NO_PUBKEY` for `pkg.jenkins.io`.
- **Cause:** Jenkins' repo signing key had changed; the old key on the VM couldn't verify it, so apt skipped that repo.
- **Impact:** Other repos (Ubuntu, Docker, HashiCorp) updated fine. Fixed in Phase 3.

## 5. IAM user had no permissions (implicit deny)
- **Error:** `Access denied to iam:ListUsers ... no identity-based policy allows the action`
- **Cause:** Created the `Admins` group with AdministratorAccess but didn't add `gokul-admin` to it. IAM denies everything by default.
- **Fix:** Logged in as root, added the user to the group, and confirmed IAM users (1).

## 6. git push failed from VS Code terminal
- **Error:** `ECONNREFUSED /run/user/1000/vscode-git-*.sock` then `Authentication failed`
- **Cause:** VS Code had reconnected, and the old terminal still pointed to VS Code's old login helper, so Git sent no credentials.
- **Fix:** Opened a new terminal and pushed again.

## 7. ping to EC2 failed but the app worked
- **Symptom:** `ping` gave 100% packet loss, but `curl http://<ip>/` returned 200.
- **Cause:** The security group allows only TCP 80 from my IP; ICMP (ping) is not allowed.
- **Lesson:** Test the real service port (`curl`, `nc -zv`), not ping.

## 8. awslogs log driver failed at boot: "no EC2 IMDS role credentials found" (404)
- **Error:** The container failed to start from `user_data` with an awslogs error saying no IAM role credentials were found in IMDS (HTTP 404).
- **Cause:** IAM eventual consistency. The instance profile was attached, but the role credentials weren't yet available from the metadata service when `user_data` ran `docker run`.
- **Fix:** `user_data` now polls `http://169.254.169.254/latest/meta-data/iam/security-credentials/` (with an IMDSv2 token) for up to about 2.5 minutes, and only starts the container once credentials are available.
- **Lesson:** In cloud bootstrap scripts, wait for the dependency to be ready instead of assuming it is.
