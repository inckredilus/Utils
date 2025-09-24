#!/data/data/com.termux/files/usr/bin/bash
# EV logging script using Termux:API dialogs

# Get timestamp
now=$(date '+%Y-%m-%d %H:%M')

# Ask for charge %
charge=$(termux-dialog text --title "Enter charge %" | jq -r '.text')
# Ask for remaining km
km=$(termux-dialog text --title "Enter remaining km" | jq -r '.text')

# Save to log file in home directory
echo "$now | Charge: $charge% | Range: $km km" >> ~/ev_notes.txt

# Optional: quick confirmation notification
termux-notification --title "EV Log" --content "Logged $charge% / $km km"
