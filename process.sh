#!/bin/bash
set -uo pipefail

PROCESS_NAME="test"
MONITORING_URL="https://test.com/monitoring/test/api"
LOG_FILE="/var/log/monitoring.log"
STATE_FILE="/var/run/process_monitor_test.state"
TIMEOUT=10

log_message() {
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] $1" >> "$LOG_FILE"
}

check_monitoring_server() {
    if curl -s -f -m "$TIMEOUT" -o /dev/null "$MONITORING_URL" 2>/dev/null; then
        return 0
    else
        log_message "ERROR: Monitoring server is not accessible at $MONITORING_URL"
        return 1
    fi
}

get_process_pid() {
    pgrep -x "$PROCESS_NAME" 2>/dev/null | head -n 1
}

read_previous_state() {
    if [[ -f "$STATE_FILE" ]]; then
        cat "$STATE_FILE"
    else
        echo ""
    fi
}

save_current_state() {
    echo "$1" > "$STATE_FILE"
}

main() {
    if [[ ! -f "$LOG_FILE" ]]; then
        touch "$LOG_FILE" 2>/dev/null || true
        chmod 644 "$LOG_FILE" 2>/dev/null || true
    fi

    current_pid=$(get_process_pid)
    
    if [[ -z "$current_pid" ]]; then
        if [[ -f "$STATE_FILE" ]]; then
            rm -f "$STATE_FILE"
        fi
        exit 0
    fi

    check_monitoring_server || true

    previous_pid=$(read_previous_state)

    if [[ -n "$previous_pid" ]] && [[ "$previous_pid" != "$current_pid" ]]; then
        log_message "INFO: Process '$PROCESS_NAME' was restarted. Old PID: $previous_pid, New PID: $current_pid"
    fi

    save_current_state "$current_pid"
    
    exit 0
}

main
