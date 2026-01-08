$ErrorActionPreference = "Stop"

# Bind to all interfaces so WSL can reach the dev server.
$env:QUARKUS_HTTP_HOST = "0.0.0.0"

# Start Postgres container in the background
docker compose up -d

# Wait until the DB is healthy (up to 60s)
$timeoutSeconds = 60
$elapsed = 0
while ($true) {
    $status = docker inspect --format '{{.State.Health.Status}}' itemsdb 2>$null

    if ($status -eq "healthy") {
        break
    }

    if ($status -eq "unhealthy") {
        throw "Container itemsdb is unhealthy"
    }

    Start-Sleep -Seconds 2
    $elapsed += 2

    if ($elapsed -ge $timeoutSeconds) {
        throw "Timed out waiting for Postgres to become healthy"
    }
}

Write-Host "Postgres is healthy. Starting Quarkus dev mode..."
./mvnw quarkus:dev
