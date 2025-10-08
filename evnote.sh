#!/usr/bin/bash
# EV charge scripts
# Start Termux dialog to record EV data to file

LOGFILE=$HOME/ev_debug.log
OUTFILE=$HOME/ev_data.txt
USRBIN=$HOME/bin

{
    echo "$(basename $0) started at $(date)"
    timestart=$(date "+%d/%m ... %H:%M")
    echo "Timestart: $timestart"

    # ==== Get last line in the datafile ====
    touch $OUTFILE
    last_line=$(tail -n 1 "$OUTFILE")

    # Abort if placeholder ("...") found in file
    if echo "$last_line" | grep -q '\.\.\.'; then
      echo "Last line has incomplete EV data, exiting."
      echo "...$last_line"
      termux-dialog -m \
         -t "Cannot add new EV data" \
         -i "Remove or complete last EV entry first" > /dev/null
      exit 0
    else
      echo  "Prompting for initial EV charging data."
    fi
 
    # Charge dialog
    raw_charge=$(termux-dialog -n -t "Enter charge (%)")
    code_charge=$(echo "$raw_charge" | jq -r '.code')
    charge=$(echo "$raw_charge" | jq -r '.text')
    echo "Charge code: $code_charge, text: $charge"

   # KM dialog
    raw_km=$(termux-dialog -n -t "Enter remaining km")
    code_km=$(echo "$raw_km" | jq -r '.code')
    km=$(echo "$raw_km" | jq -r '.text')
    echo "KM code: $code_km, text: $km"

    # Only save if both dialogs were OK
    if [ "$code_charge" = "-1" ] && [ "$code_km" = "-1" ] && \
         [ "$charge" != "null" ] && [ "$km" != "null" ] && \
         [ -n "$charge" ] && [ -n "$km" ]; then
       echo "${timestart}- ${charge}-% ${km}-" >> "$OUTFILE"
       echo "Saved note to $OUTFILE"

    # Show data or Copy to clipboard
       termux-notification \
       --id "evdata" \
       --title "Starting data for EV charging saved" \
       --content "Tap to review latest entries" \
       --button1 "Show" \
       --button1-action "sh $USRBIN/evnote_show.sh" \
       --button2 "Copy" \
       --button2-action "sh $USRBIN/evnote_show.sh copy" \
       --button3 "Clean" \
       --button3-action "sh $USRBIN/evnote_show.sh clean" \
       --priority high
    else
        termux-dialog -t "No data saved" -i "Discarding due to canceled \ 
        or empty entries" >/dev/null
        echo "No values were written to the file"
        echo "$code_charge - $charge | $code_km - $km"
    fi

    echo "Script finished"
    echo ""

} >> "$LOGFILE" 2>&1
