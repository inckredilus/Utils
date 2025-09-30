#!/data/data/com.termux/files/usr/bin/bash
# Skript för att ta sista raden i ~/ev_data.txt,
# ersätta med A,B,C,D enligt sed-kedjan,
# och sedan spara/logga/skicka resultatet.

# ==== Variabler för ersättning ====
A="22:11"
B="23456"
C="80"
D="399"

INPUT_FILE="$HOME/ev_data.txt"
DEBUG_FILE="$HOME/ev_debug.log"
CSV_FILE="$HOME/ev_data.csv"

# ==== Hämta sista raden ====
last_line=$(tail -n 1 "$INPUT_FILE")

# ==== Sed-operationer ====
result=$(echo "$last_line" | \
  sed "s/- /-$A /; s/\.\.\./$B/; s/-%/-$C%/; s/-$/-$D/")

# ==== a) skriv till debug-logg ====
echo "$(date '+%Y-%m-%d %H:%M:%S') $result" >> "$DEBUG_FILE"

# ==== b) skriv till CSV (med ; som separator) ====
# 1. ersätt flera blanktecken med ;
# 2. append till fil
csv_line=$(echo "$result" | sed 's/[[:space:]]\+/\;/g')
echo "$csv_line" >> "$CSV_FILE"

# ==== c) kopiera till clipboard ====
echo -n "$result" | termux-clipboard-set

# ==== Info till användaren ====
termux-dialog info --title "EV-data" --text "Resultat sparat:
$result

- Till $DEBUG_FILE
- Till $CSV_FILE
- Till clipboard"
