#!/usr/bin/bash

OUTFILE="$HOME/ev_data.txt"

if [ -f "$OUTFILE" ]; then
    LAST_ENTRIES=$(tail -n 3 "$OUTFILE")
    termux-dialog -t "Latest EV Data" -i "$LAST_ENTRIES"
else
    termux-dialog -t "No Data" -i "No charging entries found."
fi
