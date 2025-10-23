#!/usr/bin/bash
# EV charge scripts
# Show created datafile contents or cleanup

OUTFILE="$HOME/ev_data.txt"
CSVFILE="$HOME/ev_data.csv"
LOGFILE="$HOME/ev_debug.log"

{
# ==== a) Write to debug log ====
timestamp=$(date '+%Y-%m-%d %H:%M:%S')
echo "$(basename $0) started at $timestamp"

if [ -f "$OUTFILE" ]; then

  if [ "$1" = "copy" ]; then

    # Copy last row to clipboard
    tail -n 1 "$OUTFILE" | termux-clipboard-set
    termux-toast "Last row copied to clipboard"

  elif [ "$1" = "csv" ]; then
  
    LAST_ENTRIES=$(tail -n 3 "$CSVFILE")
    termux-dialog -t "Latest EV CSV Data" \
        -i "Data in ~/ev_data.csv: \
         $LAST_ENTRIES" > /dev/null

  elif [ "$1" = "clean" ]; then

  # Clean data file and logfile
    tail -n 5 "$OUTFILE" > "${OUTFILE}.tmp" && mv "${OUTFILE}.tmp" "$OUTFILE"    

    if [ -f "$LOGFILE" ]; then
      tail -n 20 "$LOGFILE" > "${LOGFILE}.tmp" && mv "${LOGFILE}.tmp" "$LOGFILE"
    fi
    termux-toast "Old data in ~/ev_* files cleared"

  else

# No args, print the last rows in data file
 
    LAST_ENTRIES=$(tail -n 3 "$OUTFILE")
    termux-dialog -t "Latest EV Data" \
        -i "Data in ~/ev_data.txt: \
         $LAST_ENTRIES" > /dev/null
  fi

else
    termux-dialog -t "No Data" -i "No charging entries found." >v/dev/null
fi

} >> "$LOGFILE" 2>&1
