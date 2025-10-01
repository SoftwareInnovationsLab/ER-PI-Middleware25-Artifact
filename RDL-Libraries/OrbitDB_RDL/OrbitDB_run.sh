#!/usr/bin/env bash
# Usage:
#   ./OrbitDB_run.sh start    - Start redis, build, run tests
#   ./OrbitDB_run.sh clean    - Stop redis + make clean

set -euo pipefail
IFS=$'\n\t'

ROOT="$(cd "$(dirname "$0")" && pwd)"
REDIS_LOG="$ROOT/redis.log"
REDIS_PID_FILE="$ROOT/redis.pid"

log() { echo -e "[`date +'%Y-%m-%d %H:%M:%S'`] $*"; }

# --- Redis management ---
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

# --- Build / test / clean ---
run_make_all() {
    log "Running 'make all'..."
    make all
    log "'make all' finished."
}

run_npm_test() {
    log "Running 'npm test'..."
    npm test
    log "'npm test' finished."
}

run_make_clean() {
    log "Running 'make clean'..."
    make clean
    log "'make clean' finished."
}

# --- Main ---
CMD="${1:-help}"

case "$CMD" in
    start)
        start_redis
        run_make_all
        run_npm_test
        ;;
    clean)
        run_make_clean
        stop_redis
        ;;
    restart)
        run_make_clean
        stop_redis
        start_redis
        run_make_all
        run_npm_test
        ;;
    help|*)
        cat <<EOF
Usage: $0 <command>
Commands:
  start    - Start redis-server, build project, run npm tests
  clean    - Stop redis-server and run 'make clean'
  restart  - Clean everything and start fresh
  help     - Show this message

Notes:
- Redis runs in background, logs available at $REDIS_LOG
- Reviewer-friendly, Docker-safe approach
EOF
        ;;
esac
