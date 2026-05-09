#!/usr/bin/env bash
dir="${PWD/#$HOME/~}"
default="$(whoami)@$(hostname -s):$dir"

if [ -p /dev/stdin ] || [ ! -t 0 ]; then
  raw=$(cat)
  pct=$(printf '%s' "$raw" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    pct = data.get('context_window', {}).get('used_percentage')
    if pct is not None:
        print(int(round(pct)))
except: pass
" 2>/dev/null)
fi

if [ -n "$pct" ]; then
  echo "$default    ctx:${pct}%"
else
  echo "$default"
fi
