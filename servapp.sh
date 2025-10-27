#!/data/data/com.termux/files/usr/bin/bash
# ───────────────────────────────────────────────
# BusyBox HTTPD Launcher for Termux / Widget
# Uses state file ~/.busybox_ports to track running servers
# ───────────────────────────────────────────────

BASE_DIR="$HOME/storage/shared/Prog/JavaScript"
TMP_FILE="$HOME/busyboxdir.tmp"
STATE_FILE="$HOME/.busybox_ports"
DEFAULT_PORT=8080
MAX_PORT=8100

# ───────────────────────────────────────────────
# FUNCTION: check if running from widget
detect_mode() {
    if [ -t 1 ]; then
        IS_WIDGET=false
    else
        IS_WIDGET=true
    fi
}

# ───────────────────────────────────────────────
# FUNCTION: get folder name from argument, temp file, or dialog
get_target_dir() {
    local foldername=""
    if ! $IS_WIDGET; then
        # Terminal mode
        if [ -n "$1" ]; then
            foldername="$1"
        elif [ -s "$TMP_FILE" ]; then
            foldername="$(cat "$TMP_FILE")"
        else
            read -p "Enter folder under $BASE_DIR: " foldername
        fi
    else
        # Widget mode
        if [ -s "$TMP_FILE" ]; then
            foldername="$(cat "$TMP_FILE")"
        else
            foldername=$(termux-dialog text -t "Enter folder name under $BASE_DIR" | jq -r '.text')
        fi
    fi
    TARGET_DIR="$BASE_DIR/$foldername"
    echo "$foldername" > "$TMP_FILE"
}

# ───────────────────────────────────────────────
# FUNCTION: find a free port using netcat
find_free_port() {
    local port=$DEFAULT_PORT
    while [ $port -le $MAX_PORT ]; do
        if ! nc -z 127.0.0.1 $port 2>/dev/null; then
            echo $port
            return
        fi
        port=$((port + 1))
    done
    echo ""
}

# ───────────────────────────────────────────────
# FUNCTION: check state file if folder is already served
check_existing_server() {
    if [ -f "$STATE_FILE" ]; then
        if grep -q "$TARGET_DIR" "$STATE_FILE"; then
            PORT=$(grep "$TARGET_DIR" "$STATE_FILE" | cut -d':' -f2)
            if nc -z 127.0.0.1 $PORT 2>/dev/null; then
                echo "Folder already served on port $PORT"
                am start -a android.intent.action.VIEW \
                    -d "http://127.0.0.1:$PORT/?v=$(date +%s)"
                termux-toast "App already running on port $PORT"
                exit 0
            else
                # Remove stale record
                grep -v "$TARGET_DIR" "$STATE_FILE" > "$STATE_FILE.tmp" && mv "$STATE_FILE.tmp" "$STATE_FILE"
            fi
        fi
    fi
}

# ───────────────────────────────────────────────
# FUNCTION: start BusyBox HTTP server
start_server() {
    PORT=$(find_free_port)
    if [ -z "$PORT" ]; then
        termux-toast "No available port!"
        echo "❌ No available port found."
        exit 1
    fi

    echo "Starting BusyBox on port $PORT..."
    busybox httpd -f -p $PORT -h "$TARGET_DIR" &
    SERVER_PID=$!
    sleep 0.5

    # Save to state file
    echo "$TARGET_DIR:$PORT" >> "$STATE_FILE"
    am start -a android.intent.action.VIEW \
        -d "http://127.0.0.1:$PORT/?v=$(date +%s)"
    termux-toast "Server started on port $PORT"
}

# ───────────────────────────────────────────────
# FUNCTION: validate folder
validate_dir() {
    if [ ! -d "$TARGET_DIR" ]; then
        termux-toast "Directory not found!"
        echo "❌ Directory not found: $TARGET_DIR"
        exit 1
    fi
}

# ───────────────────────────────────────────────
# FUNCTION: main logic
main() {
    detect_mode
echo "Widget? $IS_WIDGET"
    get_target_dir "$1"
    validate_dir
    check_existing_server
    start_server
}

# ───────────────────────────────────────────────
main "$@"


