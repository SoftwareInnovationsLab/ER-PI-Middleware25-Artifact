#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_DIR="/artifact/artifact_logs/roshi/all_related_logs"
mkdir -p "$LOG_DIR"

CLUSTER_DIR="$ROOT/cluster"
REDIS_LOG="$LOG_DIR/redis.log"
REDIS_PID_FILE="$ROOT/redis.pid"

log() {
    echo "[roshi_run] $*"
}

start_redis() {
    # Always try to kill any redis-server first (safe cleanup)
    if pgrep redis-server > /dev/null; then
        log "Killing old redis-server processes..."
        pkill -9 redis-server || true
    fi

    # Clean up stale PID file
    rm -f "$REDIS_PID_FILE"

    # Start fresh redis
    log "Starting redis-server in background..."
    nohup redis-server --port 6379 --daemonize no > "$REDIS_LOG" 2>&1 &
    echo $! > "$REDIS_PID_FILE"
    sleep 1  # give it a moment to bind
    if ! kill -0 $(cat "$REDIS_PID_FILE") 2>/dev/null; then
        log "ERROR: redis-server failed to start. See $REDIS_LOG"
        exit 1
    fi
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
    else
        # fallback: kill any redis still alive
        if pgrep redis-server > /dev/null; then
            log "Killing stray redis-server processes..."
            pkill -9 redis-server || true
        fi
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
    rm -f "$LOG_DIR"/*.log "$ROOT"/*.pid
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
