#!/usr/bin/bash

OUTFILE="$HOME/ev_data.txt"
LOGFILE="$HOME/ev_debug.log"
77
if [ -f "$OUTFILE" ]; then

  if [ "$1" = "copy" ]; then

    # Copy last row to clopboard
    tail -n 1 "$OUTFILE" | termux-clipboard-set
    termux-toast "Last row copied to clipboard"

  elif [ "$1" = "clean" ]; then

  # Clean data file and logfile
    tail -n 5 "$OUTFILE" > "${OUTFILE}.tmp" && mv "${OUTFILE}.tmp" "$OUTFILE"    

    if [ -f "$LOGFILE" ]; then
      tail -n 8 "$LOGFILE" > "${LOGFILE}.tmp" && mv "${LOGFILE}.tmp" "$LOGFILE"
    fi
    termux-toast "Old data in ~/ev_* files cleared"

  else

# No args, print the last rows in data file
    LAST_ENTRIES=$(tail -n 3 "$OUTFILE")
    termux-dialog -t "Latest EV Data" -i "$LAST_ENTRIES"
  fi

else
    termux-dialog -t "No Data" -i "No charging entries found."
fi

