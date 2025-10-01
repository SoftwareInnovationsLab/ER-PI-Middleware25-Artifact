#!/usr/bin/env bash

# Usage:
#   ./goRDL_run.sh start    - Start redis, build, launch replicas
#   ./goRDL_run.sh stop     - Stop replicas
#   ./goRDL_run.sh clean    - Stop everything and run make clean

set -euo pipefail
IFS=$'\n\t'

ROOT="$(cd "$(dirname "$0")" && pwd)"
LOG_DIR="/artifact/artifact_logs/Go_RDL/all_related_logs"
mkdir -p "$LOG_DIR"
REDIS_LOG="$LOG_DIR/redis.log"
R1_LOG="$LOG_DIR/r1.log"
R2_LOG="$LOG_DIR/r2.log"
R1_PID_FILE="$ROOT/r1.pid"
R2_PID_FILE="$ROOT/r2.pid"
REDIS_PID_FILE="$ROOT/redis.pid"

# --- Helper Functions ---
log() { echo -e "[`date +'%Y-%m-%d %H:%M:%S'`] $*"; }

start_redis() {
    # Always try to kill any redis-server first
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

run_make_all() {
    log "Running 'make all'. ⏳ This step includes a 20-second wait!\n\n"
    make all
    log "'make all' finished."
}

start_replicas() {
    log "Starting replicas in background..."
    ./Library/r1.sh > "$R1_LOG" 2>&1 &
    R1_PID=$!
    echo $R1_PID > "$R1_PID_FILE"
    log "Replica 1 started with PID $R1_PID, logs at $R1_LOG"

    ./Library/r2.sh > "$R2_LOG" 2>&1 &
    R2_PID=$!
    echo $R2_PID > "$R2_PID_FILE"
    log "Replica 2 started with PID $R2_PID, logs at $R2_LOG"

    log "⏳🔛 Replicas are running in background. Interleavings can take several moments to be replayed.\n\n"
    log "Monitor progress at $R1_LOG and\n $R2_LOG\n\n"
}

stop_replicas() {
    for pidfile in "$R1_PID_FILE" "$R2_PID_FILE"; do
        if [[ -f "$pidfile" ]]; then
            PID=$(cat "$pidfile")
            if kill -0 $PID 2>/dev/null; then
                log "Stopping process PID $PID and interleavings replay...\n"
                kill $PID
            fi
            rm -f "$pidfile"
        fi
    done
}

do_clean() {
    log "Running make clean..."
    make clean
    stop_replicas
    stop_redis
    log "Cleanup complete."
}

# --- Main ---
CMD="${1:-help}"

case "$CMD" in
    start)
        start_redis
        run_make_all
        start_replicas
        ;;
    stop)
        stop_replicas
        ;;
    clean)
        do_clean
        ;;
    restart)
        do_clean
        start_redis
        run_make_all
        start_replicas
        ;;
    help|*)
        cat <<EOF
Usage: $0 <command>
Commands:
  start    - Start redis-server, build project, launch replicas
  stop     - Stop replicas
  clean    - Stop everything and run 'make clean'
  restart  - Clean + start again
  help     - Show this message

Notes:
- Replicas run in background, logs available at $R1_LOG and $R2_LOG
- 'make all' includes a 20-second sleep; please wait until it finishes
EOF
        ;;
esac
