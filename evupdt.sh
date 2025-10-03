#!/usr/bin/bash
# Script to process last line in ~/ev_data.txt,
# replace placeholders with user-provided values,
# update source file, save results to debug log & CSV,
# copy result to clipboard, and send Termux notification.

INPUT_FILE="$HOME/ev_data.txt"
DEBUG_FILE="$HOME/ev_debug.log"
CSV_FILE="$HOME/ev_data.csv"
USRBIN="$HOME/bin"

# ==== Check if we have a terminal (for widget start) ====
if [ ! -t 0 ]; then
  am start -n com.termux/.app.TermuxActivity \
    -e com.termux.execute.background "$0"
  exit 0
fi

# ==== Read values from user ====
read -r -p "Enter Endtime (hh:mm): " A
read -r -p "Enter Total km (B): " B
read -r -p "Enter %-loaded (C, number only): " C
read -r -p "Enter km (D): " D

# ==== Get last line ====
last_line=$(tail -n 1 "$INPUT_FILE")

# ==== Sed replacements ====
result=$(echo "$last_line" | \
  sed "s/- /-$A /; s/\.\.\./$B/; s/-%/-$C%/; s/-$/-$D/")

# ==== Replace last line in input file with result ====
tmpfile=$(mktemp)
head -n -1 "$INPUT_FILE" > "$tmpfile"
echo "$result" >> "$tmpfile"
mv "$tmpfile" "$INPUT_FILE"

# ==== a) Write to debug log ====
script_name=$(basename "$0")
timestamp=$(date '+%Y-%m-%d %H:%M:%S')
{
  echo "[$timestamp] ($script_name)"
  echo "Result: $result"
} >> "$DEBUG_FILE" 2>&1

# ==== b) Write to CSV file ====
# Add header if file does not exist
if [ ! -f "$CSV_FILE" ]; then
  echo "Date;Duration;Total km;%-loaded;km;" > "$CSV_FILE"
fi
# Convert dd/mm to ISO yyyy-mm-dd and format as CSV
csv_line=$(echo "$result" \
  | sed -E 's#^([0-9]{2})/([0-9]{2})(.*)#2025-\2-\1\3#' \
  | sed 's/[[:space:]]\+/\;/g; s/$/;/')
echo "$csv_line" >> "$CSV_FILE"

# ==== c) Copy to clipboard ====
echo -n "$result" | termux-clipboard-set > /dev/null 2>&1

# ==== d) Notification ====
termux-notification \
  --id "evdata" \
  --title "EV-data updated" \
  --content "$result" \
  --button1-text "Show" \
  --button1-action "$USRBIN/evnote_show.sh" \
  --button2-text "Copy" \
  --button2-action "$USRBIN/evnote_show.sh copy" \
  > /dev/null 2>&1
