# Add a pattern to the current repo's local exclude file (not committed)
function git-exclude {
  if [ $# -eq 0 ]; then
    echo "Usage: git-exclude <pattern>"
    return 1
  fi
  local exclude_file
  exclude_file="$(git rev-parse --git-dir 2>/dev/null)/info/exclude"
  if [ -z "$exclude_file" ]; then
    echo "Not inside a git repository"
    return 1
  fi
  mkdir -p "$(dirname "$exclude_file")"
  echo "$1" >> "$exclude_file"
  echo "Added '$1' to $exclude_file"
}
