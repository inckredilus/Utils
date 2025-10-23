#!/usr/bin/bash
# EV charge scripts
# Script to process last line in ~/ev_data.txt,
# replace placeholders with user-provided values,
# update source file, save results to debug log & CSV,
# copy result to clipboard, and send Termux notification.

OUTFILE="$HOME/ev_data.txt"
LOGFILE="$HOME/ev_debug.log"
CSVFILE="$HOME/ev_data.csv"
USRBIN="$HOME/bin"

{
# ==== a) Write to debug log ====
timestamp=$(date '+%Y-%m-%d %H:%M:%S')
echo "$(basename $0) started at $timestamp"
#echo "Shell: $SHELL"

# ==== Get last line in the datafile ====
touch $OUTFILE
last_line=$(tail -n 1 "$OUTFILE")

# Abort if placeholder ("...") is not found
if ! echo "$last_line" | grep -q '\.\.\.'; then
  echo "Last line already converted, exiting." 
  echo "...$last_line"
  termux-dialog -m -t "No data to edit" \
     -i "Last line has complete EV data already." > /dev/null
  exit 0
else 
  echo  "Prompting for EV charging data."
fi

# ==== Check if we have a terminal (for widget start) ====
if [ ! -t 0 ]; then
  echo "Running fron a Widget, no terminal"

# ==== NEW: Possible to modify initial data

# Example last_line:
# last_line="07/10 ... 10:45- 82-% 382-"

# --- Extract first 3 fields ---
read date val time <<< $(echo "$last_line" | awk '{print $1, $2, $3}')

# --- Ask user for Start Date ---
resp=$(termux-dialog text -t "Start Date" -i "$date")
code=$(echo "$resp" | jq -r '.code')
[ "$code" = "-2" ] && termux-toast "Canceled." && exit 1

newdate=$(echo "$resp" | jq -r '.text // empty')
[ -n "$newdate" ] && date="$newdate"

# --- Ask user for Start Time ---
resp=$(termux-dialog text -t "Start Time" -i "${time%-}")
code=$(echo "$resp" | jq -r '.code')
[ "$code" = "-2" ] && termux-toast "Canceled." && exit 1

newtime=$(echo "$resp" | jq -r '.text // empty')
[ -n "$newtime" ] && time="$newtime"

# --- Ensure trailing dash on time ---
[[ "$time" != *- ]] && time="${time}-"

# --- Rebuild the line, preserving dummy and other columns ---
last_line=$(echo "$last_line" | awk -v d="$date" -v t="$time" '{ $1=d; $3=t; OFS=" "; print $0 }')

echo "Updated last line:"
echo "$last_line"

# ==== END NEW

# ==== Enter data for competled EV charging
  json=$(termux-dialog text -m \
    -t $'Mileage  Endtime  %-loaded  Range'  \
    -i 'Enter 4 EV charging data values in the order above, each on a new line, end with OK')

  # Extract 'text' field from JSON
  text=$(echo "$json" | jq -r '.text')

  # Split lines into array (mapfile OK in bash)
  mapfile -t vars <<< "$text"
#  IFS=$'\n' read -r -d '' -a vars <<EOF
#$text
#EOF

  # Assign variables
  A=${vars[0]}   # Milleage
  B=${vars[1]}   # Endtime
  C=${vars[2]}   # %-loaded
  D=${vars[3]}   # Range

fi

} >> "$LOGFILE" 2>&1

if [ -t 0 ]; then
  # ==== Read user input (no logfile log)  ====

  echo  "Enter data for EV charging complete."

  read -r -p "Vehicle Milleage (km): " A
  read -r -p "Charge Endtime (hh:mm): " B
  read -r -p "%-loaded (number only): " C
  read -r -p "Current Range (km): " D

fi

{
echo "User input: Mileage:$A Endtime:$B  %-loaded:$C Range:$D"

# Only save if inout data is OK
if [ "$A" != "null" ] && [ "$B" != "null" ] && \
   [ "$C" != "null" ] && [ "$D" != "null" ] && \
   [ -n "$A" ] && [ -n "$B" ] && [ -n "$C" ] && [ -n "D" ]; then

# ==== Sed replacements ====
result=$(echo "$last_line" | \
  sed "s/\.\.\./$A/; s/- /-$B /; s/-%/-$C%/; s/-$/-$D/")

# ==== Replace last line in input file with result ====
tmpfile=$(mktemp)
head -n -1 "$OUTFILE" > "$tmpfile"
echo "$result" >> "$tmpfile"
mv "$tmpfile" "$OUTFILE"

# ==== b) Write to CSV file ====
# Add header if file does not exist
if [ ! -f "$CSVFILE" ]; then
  echo "Date;Milleage;Endtime;%-loaded;Range;" > "$CSVFILE"
fi
# Convert dd/mm to ISO yyyy-mm-dd and format as CSV
year=$(date +%Y)
csv_line=$(echo "$result" \
  | sed -E "s#^([0-9]{1,2})/([0-9]{1,2})(.*)#$year-\2-\1\3#" \
  | sed "s/[[:space:]]\+/\;/g; s/$/;/")
echo "$csv_line" >> "$CSVFILE"

# ==== c) Copy to clipboard ====
echo -n "$result" | termux-clipboard-set > /dev/null 2>&1

# ==== d) Notification ====
termux-notification \
  --id "evdata" \
  --title "Data saved for EV charging complete" \
  --content "Tap to review or copy result" \
  --button3 "Show" \
  --button3-action "sh $USRBIN/evnote_show.sh" \
  --button1 "Copy" \
  --button1-action "sh $USRBIN/evnote_show.sh copy" \
  --button2 "CSV" \
  --button2-action "sh $USRBIN/evnote_show.sh csv" \
  --priority high

else
    termux-dialog -t "No data saved" -i "Discarding due to canceled \ 
    or empty entries" >/dev/null
        echo "No values were written to the file"
fi

echo "script finished."
echo ""

} >> "$LOGFILE" 2>&1
