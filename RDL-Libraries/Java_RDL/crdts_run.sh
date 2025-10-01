#!/usr/bin/env bash

set -euo pipefail
IFS=$'\n\t'

ROOT="$(cd "$(dirname "$0")" && pwd)"
LOG_DIR="/artifact/artifact_logs/Java_RDL/all_related_logs"
mkdir -p "$LOG_DIR"
REDIS_LOG="$LOG_DIR/redis.log"
TEST_LOG="$LOG_DIR/test_res.log"

REDIS_PID_FILE="$ROOT/redis.pid"

GRADLE_RUN_PID="$ROOT/gradle_run.pid"
INTERLEAVE_PID="$ROOT/interleave.pid"

log() { echo -e "[`date +'%Y-%m-%d %H:%M:%S'`] $*"; }

# --- Redis ---
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
    bash -c "cd '$ROOT' && ./interleave" > "$LOG_DIR/interleave.log" 2>&1
    log "Interleave finished. Logs at $LOG_DIR/interleave.log"

    log "Starting Gradle run in detached mode..."
    nohup bash -c "cd '$ROOT' && gradle run --console=plain" > "$TEST_LOG" 2>&1 &
    echo $! > "$GRADLE_RUN_PID"
    log "Gradle run started in detached mode. Outputs logged to $TEST_LOG"
    log "You can monitor logs: $TEST_LOG"
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
