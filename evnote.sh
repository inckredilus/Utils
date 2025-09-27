#!/data/data/com.termux/files/usr/bin/bash

LOGFILE=~/ev_debug.log
OUTFILE=~/ev_data.txt

{
    echo "Script started at $(date)"
#    echo "Timestamp: $(date "+%Y-%m-%d %H:%M")"
    timestamp=$(date "+%d/%m %H:%M")
    echo "Timestamp: $timestamp"


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
       echo "$timestamp | Charge: ${charge}% | KM: ${km}" >> "$OUTFILE"
       echo "Saved note to $OUTFILE"

   termux-notification \
      --id "evdata" \
      --title "New EV data saved" \
      --content "Tap to review latest entries" \
      --button1 "Show data" \
      --button1-action "sh $HOME/.shortcuts/evnote_show.sh" \
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
