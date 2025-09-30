#!/usr/bin/env bash
# goRDL_run.sh - Unified build/test/run/cleanup script for Go_RDL
# Usage:
#   ./goRDL_run.sh start    - Start redis, build, launch replicas
#   ./goRDL_run.sh stop     - Stop replicas
#   ./goRDL_run.sh clean    - Stop everything and run make clean

set -euo pipefail
IFS=$'\n\t'

ROOT="$(cd "$(dirname "$0")" && pwd)"
REDIS_LOG="$ROOT/redis.log"
R1_LOG="$ROOT/r1.log"
R2_LOG="$ROOT/r2.log"
R1_PID_FILE="$ROOT/r1.pid"
R2_PID_FILE="$ROOT/r2.pid"
REDIS_PID_FILE="$ROOT/redis.pid"

# --- Helper Functions ---
log() { echo -e "[`date +'%Y-%m-%d %H:%M:%S'`] $*"; }

start_redis() {
    log "Stopping any existing redis-server..."
    sudo systemctl stop redis-server || true
    log "Starting redis-server in background..."
    redis-server > "$REDIS_LOG" 2>&1 &
    echo $! > "$REDIS_PID_FILE"
    log "Redis started with PID $(cat $REDIS_PID_FILE), logs at $REDIS_LOG"
}

stop_redis() {
    if [[ -f "$REDIS_PID_FILE" ]]; then
        PID=$(cat "$REDIS_PID_FILE")
        if kill -0 $PID 2>/dev/null; then
            log "Stopping redis-server PID $PID"
            kill $PID
            rm -f "$REDIS_PID_FILE"
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
    log "Monitor progress with: tail -f $R1_LOG\n and $R2_LOG\n\n"
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
