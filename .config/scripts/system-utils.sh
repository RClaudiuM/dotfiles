#!/bin/bash
# System utilities using fzf

# Interactive process killing
function fkill() {
  if [ "$1" = "-p" ] || [ "$1" = "--port" ]; then
    # Kill process by port
    local port="$2"
    if [ -z "$port" ]; then
      echo "Error: Port number is required"
      return 1
    fi
    
    local pid
    pid=$(lsof -i :${port} -t)
    if [ -n "$pid" ]; then
      echo "Killing process on port $port (PID: $pid)"
      kill -9 $pid
    else
      echo "No process found on port $port"
    fi
  else
    # Interactive kill using fzf
    local pid
    pid=$(ps -f -u $USER | sed 1d | fzf --height 40% --multi | awk '{print $2}')
    if [ -n "$pid" ]; then
      echo "Killing: $pid"
      kill -9 $pid
    fi
  fi
}

# Interactive man page browser
function fman() {
  man -k . | fzf --prompt='Man> ' | awk '{print $1}' | xargs -r man
}

# Interactive command history search
function fhistory() {
  local cmd
  cmd=$(history | cut -c 8- | sort -u | fzf --height 40%)
  if [ -n "$cmd" ]; then
    echo "$cmd" | tr -d '\n'
    echo "Command: $cmd"
  fi
}
