# Get my public IP
function myip {
  dig +short txt ch whoami.cloudflare @1.0.0.1 | tr -d '"'
}

# List processes listening on TCP ports, optionally filtered by pattern
function listening {
  if [ $# -eq 0 ]; then
    sudo lsof -iTCP -sTCP:LISTEN -n -P
  elif [ $# -eq 1 ]; then
    sudo lsof -iTCP -sTCP:LISTEN -n -P | grep -i --color $1
  else
    echo "Usage: listening [pattern]"
  fi
}
