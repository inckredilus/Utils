#!/data/data/com.termux/files/usr/bin/sh

OUTFILE="$HOME/evnotes.txt"

if [ -f "$OUTFILE" ]; then
    LAST_ENTRIES=$(tail -n 3 "$OUTFILE")
    termux-dialog -t "Latest EV Data" -i "$LAST_ENTRIES"
else
    termux-dialog -t "No Data" -i "No entries found yet."
fi
