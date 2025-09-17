# Alias for this script and cd to back here
echo "Loading"
alias x='. /storage/emulated/0/x'
alias xx='cd /storage/emulated/0;PS1="\w \$ "'

echo "Choose a project:"
echo "1) Python"
echo "2) Jupyter"
echo "3) Jupyter notebook"

printf "Enter choice (default=1): "
read choice

case "$choice" in
  ""|1)   # Default = Python
    cd /storage/emulated/0/Prog/Python
    ;;
  2)
    cd /storage/emulated/0/Prog/Jupyter
    ;;
  3)
    cd /storage/emulated/0/Prog/Jupyter
    jupyter-notebook &
    ;;
  *)
    target="/storage/emulated/0/Prog/$choice"
    if [ -d "$target" ]; then
      cd "$target"
    else
      echo "Directory $choice' not found in Prog:"
      ls /storage/emulated/0/Prog/
      x
    fi
    ;;
esac

# Set prompt  to basename only
PS1='\W \$ '
