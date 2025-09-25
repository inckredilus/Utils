#!/data/data/com.termux/files/usr/bin/bash

LOGFILE=~/ev_debug.log
OUTFILE=~/ev_data.txt

{
    echo "Script started at $(date)"
    timestamp=$(date "+%Y-%m-%d %H:%M")
    echo "Timestamp: $timestamp"

    # Charge dialog
    raw_charge=$(termux-dialog -t "Enter charge (%)")
    code_charge=$(echo "$raw_charge" | jq -r '.code')
    charge=$(echo "$raw_charge" | jq -r '.text')
    echo "Charge code: $code_charge, text: $charge"

    # KM dialog
    raw_km=$(termux-dialog -t "Enter remaining km")
    code_km=$(echo "$raw_km" | jq -r '.code')
    km=$(echo "$raw_km" | jq -r '.text')
    echo "KM code: $code_km, text: $km"

    # Only save if both dialogs were OK
    if [ "$code_charge" = "-1" ] && [ "$code_km" = "-1" ] && \
         [ "$charge" != "null" ] && [ "$km" != "null" ] && \
         [ -n "$charge" ] && [ -n "$km" ]; then
       echo "$timestamp | Charge: ${charge}% | KM: ${km}" >> "$OUTFILE"
       echo "Saved note to $OUTFILE"
    else
        termux-dialog -t "No data saved" -i "Discarding due to canceled \ 
        or empty entries" >/dev/null
        echo "No values were written to the fils"
        echo "$code_charge - $charge | $code_km - $km"
    fi

    echo "Script finished"
    echo ""
} >> "$LOGFILE" 2>&1
