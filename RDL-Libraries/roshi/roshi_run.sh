#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLUSTER_DIR="$ROOT/cluster"
REDIS_LOG="$ROOT/redis.log"
REDIS_PID_FILE="$ROOT/redis.pid"

log() {
    echo "[roshi_run] $*"
}

start_redis() {
    # Stop existing Redis if running
    if [[ -f "$REDIS_PID_FILE" ]]; then
        PID=$(cat "$REDIS_PID_FILE")
        if kill -0 $PID 2>/dev/null; then
            log "Stopping existing redis-server PID $PID"
            kill $PID || true
        fi
        rm -f "$REDIS_PID_FILE"
    fi

    log "Starting redis-server in background..."
    nohup redis-server > "$REDIS_LOG" 2>&1 &
    echo $! > "$REDIS_PID_FILE"
    log "Redis started with PID $(cat $REDIS_PID_FILE), logs at $REDIS_LOG"
}

stop_redis() {
    if [[ -f "$REDIS_PID_FILE" ]]; then
        PID=$(cat "$REDIS_PID_FILE")
        if kill -0 $PID 2>/dev/null; then
            log "Stopping redis-server PID $PID"
            kill $PID || true
        fi
        rm -f "$REDIS_PID_FILE"
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
    rm *.log *.pid
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
