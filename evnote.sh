#!/data/data/com.termux/files/usr/bin/bash

LOGFILE=~/ev_debug.log
OUTFILE=~/ev_data.txt

{
    echo "Script started at $(date)"
    timestamp=$(date "+%Y-%m-%d %H:%M")
    echo "Timestamp: $timestamp"

    # Ask for charge %
    raw_charge=$(termux-dialog -t "Enter charge (%)")
    echo "Raw charge dialog output: $raw_charge"
    charge=$(echo "$raw_charge" | jq -r '.text')

    # Ask for km
    raw_km=$(termux-dialog -t "Enter remaining km")
    echo "Raw km dialog output: $raw_km"
    km=$(echo "$raw_km" | jq -r '.text')

    # Save to file if input is not empty
    if [ -n "$charge" ] || [ -n "$km" ]; then
        echo "$timestamp | Charge: ${charge}% | KM: ${km}" >> "$OUTFILE"
        echo "Saved note to $OUTFILE"
    else
        echo "No input provided"
    fi

    echo "Script finished"
    echo ""
} >> "$LOGFILE" 2>&1
