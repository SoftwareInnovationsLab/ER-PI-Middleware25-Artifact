#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLUSTER_DIR="$ROOT/cluster"

log() {
    echo "[roshi_run] $*"
}

start_redis() {
    log "Stopping any existing redis-server..."
    sudo systemctl stop redis-server || true

    log "Starting new redis-server in background..."
    nohup redis-server > "$ROOT/redis.log" 2>&1 &
    echo $! > "$ROOT/redis.pid"
    log "redis-server PID $(cat "$ROOT/redis.pid") (logs: $ROOT/redis.log)"
    sleep 2
}

stop_redis() {
    if [[ -f "$ROOT/redis.pid" ]]; then
        log "Stopping redis-server PID $(cat "$ROOT/redis.pid")..."
        kill "$(cat "$ROOT/redis.pid")" || true
        rm -f "$ROOT/redis.pid"
    fi
}

start() {
    start_redis
    trap stop_redis EXIT

    log "Running make all in cluster/..."
    make -C "$CLUSTER_DIR" all

    log "Running go test cluster_test.go..."
    (cd "$CLUSTER_DIR" && go test cluster_test.go)

    log "✅ Done."
}

clean() {
    log "Running make clean in cluster/..."
    make -C "$CLUSTER_DIR" clean
    rm *.log
    log "Clean complete."
}

main() {
    case "${1:-}" in
        start) start ;;
        clean) clean ;;
        *)
            echo "Usage: $0 {start|clean}"
            exit 1
            ;;
    esac
}

main "$@"
