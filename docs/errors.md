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
