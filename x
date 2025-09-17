# Alias for this script and cd to back here
echo "Jupyter Notebook wrapper"
alias x='. /storage/emulated/0/x'
alias xx='cd /storage/emulated/0;PS1="\w \$ "'

echo "Choose project or type directory name:"
echo "1) Python"
echo "2) Jupyter"
echo "3) MDdocs"
echo "4) Utils"

printf "Enter choice: "
read choice

case "$choice" in
  ""|1)   # Default = Python
    cd /storage/emulated/0/Prog/Python
    ;;
  2)
    cd /storage/emulated/0/Prog/Jupyter
    ;;
  3)
    cd /storage/emulated/0/Prog/MDdocs
    ;;
  4)
    cd /storage/emulated/0/Prog/Utils
    ;;
  *)
    target="/storage/emulated/0/Prog/$choice"
    if [ -d "$target" ]; then
      cd "$target"
    else
      echo "Directory $choice' not found in Prog:"
      ls /storage/emulated/0/Prog/
    fi
    ;;
esac

# Start jupyter notebook

if env | grep -qi pydroid; then
    echo "Running inside Pydroid – starting Jupyter..."
    jupyter-notebook &
else
    echo "Not in Pydroid – skipping Jupyter."
fi


# Set prompt to basename only
PS1='\W \$ '
