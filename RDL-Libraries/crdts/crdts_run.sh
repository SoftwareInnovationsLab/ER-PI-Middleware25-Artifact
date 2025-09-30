#!/usr/bin/env bash
# crdts_run.sh - Detached, reviewer-friendly run script for CRDTs

set -euo pipefail
IFS=$'\n\t'

ROOT="$(cd "$(dirname "$0")" && pwd)"
REDIS_LOG="$ROOT/redis.log"
REDIS_PID_FILE="$ROOT/redis.pid"

TEST_LOG="$ROOT/test_res.log"
GRADLE_RUN_PID="$ROOT/gradle_run.pid"
INTERLEAVE_PID="$ROOT/interleave.pid"

log() { echo -e "[`date +'%Y-%m-%d %H:%M:%S'`] $*"; }

# --- Redis ---
start_redis() {
    log "Stopping any existing redis-server..."
    sudo systemctl stop redis-server || true
    log "Starting redis-server in background..."
    redis-server > "$REDIS_LOG" 2>&1 &
    echo $! > "$REDIS_PID_FILE"
    log "Redis started with PID $(cat $REDIS_PID_FILE), logs at $REDIS_LOG"
}

stop_redis() {
    [[ -f "$REDIS_PID_FILE" ]] && kill $(cat "$REDIS_PID_FILE") 2>/dev/null || true
    rm -f "$REDIS_PID_FILE"
}

# --- Stop background processes ---
stop_background() {
    for pidfile in "$GRADLE_RUN_PID" "$INTERLEAVE_PID"; do
        if [[ -f "$pidfile" ]]; then
            PID=$(cat "$pidfile")
            if kill -0 $PID 2>/dev/null; then
                log "Stopping PID $PID"
                kill $PID || true
            fi
            rm -f "$pidfile"
        fi
    done
}

# --- Build & Run ---
run_all() {
    log "Running 'make datalog ils build'..."
    make datalog ils build

    log "Running ./interleave to generate interleavings (synchronous)..."
    bash -c "cd '$ROOT' && ./interleave" > "$ROOT/interleave.log" 2>&1
    log "Interleave finished. Logs at $ROOT/interleave.log"

    log "Starting Gradle run in detached mode..."
    nohup bash -c "cd '$ROOT' && gradle run --console=plain" > "$TEST_LOG" 2>&1 &
    echo $! > "$GRADLE_RUN_PID"
    log "Gradle run started in detached mode. Outputs logged to $TEST_LOG"
    log "You can monitor logs: tail -f $TEST_LOG"
    log "⏳ Please wait a bit moments as it takes time to invoke events and generate interleavings..."
    log "You can stop testing anytime using './crdts_run.sh stop'"
}

run_test() {
    log "Running 'gradle test'..."
    gradle test > "$TEST_LOG" 2>&1
    log "'gradle test' finished. Outputs written to: $TEST_LOG"
}

run_clean() {
    log "Running 'make clean'..."
    make clean
    stop_background
    stop_redis
    log "Clean finished."
}

CMD="${1:-help}"

case "$CMD" in
    start)
        start_redis
        run_all
        ;;
    stop)
        stop_background
        stop_redis
        ;;
    clean)
        run_clean
        ;;
    restart)
        run_clean
        start_redis
        run_all
        ;;
    help|*)
        cat <<EOF
Usage: $0 <command>
Commands:
  start    - Start redis-server, build, run Gradle in detached mode
  stop     - Stop Gradle run and redis-server
  clean    - Run 'make clean' and stop all processes
  restart  - Clean and start fresh
  help     - Show this message

Notes:
- Interleavings are generated before Gradle run, avoiding "File does not exist"
- Gradle outputs are logged to: $TEST_LOG
- Interleave outputs are logged to: $ROOT/interleave.log
- Reviewer can monitor logs using: tail -f $TEST_LOG
- All processes are stoppable using './crdts_run.sh stop'
EOF
        ;;
esac
