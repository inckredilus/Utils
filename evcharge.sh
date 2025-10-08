#!/usr/bin/bash
# EV charge scripts
# Starts EV charge scripts - Start Clean Complete
# intentdet for termux-widget startup 

LOGFILE=$HOME/ev_debug.log
USRBIN=$HOME/bin

{
echo "Starting EV charge..."
termux-notification \
  --id "evdata" \
  --title "App that records EV charging data" \
  --content "Tap whether you are Starting or \
    Updating your entry" \
  --button1 "Start" \
  --button1-action "sh $USRBIN/evnote.sh" \
  --button2 "Complete" \
  --button2-action "bash $USRBIN/evupdt.sh" \
  --button3 "Show" \
  --button3-action "sh $USRBIN/evnote_show.sh" \
  --priority high 

} >> "$LOGFILE" 2>&1
