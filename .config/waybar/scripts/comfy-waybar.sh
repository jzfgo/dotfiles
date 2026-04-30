#!/usr/bin/env bash
FILE="${COMFY_WAYBAR_OUT:-/tmp/comfy_progress.json}"

if [ ! -f "$FILE" ]; then
  echo "🧠 Comfy"
  exit 0
fi

status=$(jq -r '.status // "unknown"' "$FILE")
pending=$(jq -r '.queue_pending // 0' "$FILE")
runningq=$(jq -r '.queue_running // 0' "$FILE")
percent=$(jq -r '.percent // empty' "$FILE")
node=$(jq -r '.node // empty' "$FILE")

case "$status" in
  running)
    if [ -n "$percent" ]; then
      echo "🧠 ${percent}%  ⏳${pending}"
    else
      echo "🧠 …  ⏳${pending}"
    fi
    ;;
  idle)
    if [ "$pending" -gt 0 ]; then
      echo "⏳ ${pending}"
    else
      echo "✅"
    fi
    ;;
  error)
    echo "❌ Comfy"
    ;;
  connecting|connected|disconnected|unknown|*)
    echo "🧠 ${status}  ⏳${pending}"
    ;;
esac

