#!/usr/bin/bash
# Script to process last line in ~/ev_data.txt,
# replace placeholders with user-provided values,
# and save results to debug log, CSV file, and clipboard.

INPUT_FILE="$HOME/ev_data.txt"
DEBUG_FILE="$HOME/ev_debug.log"
CSV_FILE="$HOME/ev_data.csv"

# ==== Read values from user ====
echo "Enter Endtime (hh:mm):"
read -r A
#read -r -p "Enter Endtime km " A B C D
echo "Enter Total km (B):"
read -r B
echo "Enter %-loaded (C, number only):"
read -r C
echo "Enter km (D):"
read -r D

# ==== Get last line ====
last_line=$(tail -n 1 "$INPUT_FILE")

# ==== Sed replacements ====
result=$(echo "$last_line" | \
  sed "s/- /-$A /; s/\.\.\./$B/; s/-%/-$C%/; s/-$/-$D/")

# ==== a) Write to debug log ====
echo "$(date '+%Y-%m-%d %H:%M:%S') $result" >> "$DEBUG_FILE"

# ==== b) Write to CSV file ====
# Add header if file does not exist
if [ ! -f "$CSV_FILE" ]; then
  echo "Date;Duration;Total km;%-loaded;km;" > "$CSV_FILE"
fi
# Replace multiple spaces with ";" and add trailing ";"
#csv_line=$(echo "$result" | sed 's/[[:space:]]\+/\;/g; s/$/;/')
#result="29/09 19:28-22:11 23456 49-80% 199-399"
csv_line=$(echo "$result" \
  | sed -E 's#^([0-9]{2})/([0-9]{2})(.*)#2025-\2-\1\3#' \
  | sed 's/[[:space:]]\+/\;/g; s/$/;/')
echo "$csv_line"
echo "$csv_line" >> "$CSV_FILE"

# ==== c) Copy to clipboard ====
echo -n "$result" | termux-clipboard-set > /dev/null

# ==== Info dialog ====
termux-dialog -t "EV-data" -i "Result:
$result

-  $(basename $DEBUG_FILE)
-  $(basename $CSV_FILE)
-  clipboard" > /dev/null
