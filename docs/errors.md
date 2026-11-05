# Errors faced & fixes

## 1. apt lock held by unattended-upgrade
- **Error:** `Could not get lock /var/lib/dpkg/lock-frontend. It is held by process 5781 (unattended-upgr)`
- **Cause:** Ubuntu's automatic security updates were running in the background.
- **Fix:** Found the process with `ps -ef | grep 5781`. Waited for it to finish instead of killing it (killing it can corrupt the dpkg database).

## 2. Port 8080 already in use
- **Error:** `Web server failed to start. Port 8080 was already in use.`
- **Cause:** Jenkins was already listening on 8080 on the VM.
- **Fix:** Confirmed with `ps -ef | grep 8080` / `ss -tlnp`. Ran the app locally on 8081 (`--server.port=8081`). In Docker the app keeps 8080 inside the container and is mapped with `-p 8081:8080`.
