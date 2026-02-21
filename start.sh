#!/bin/sh
# Start WhatsApp bridge (Node.js) in the background, then run nanobot gateway.
# Gateway auto-restarts on exit (e.g. when nanobot restarts itself via exec tool).

CONFIG="/root/.nanobot/config.json"

# Restore OAuth token from persistent volume if present
OAUTH_SRC="/root/.nanobot/oauth-codex.json"
OAUTH_DST="/root/.local/share/oauth-cli-kit/auth/codex.json"
if [ -f "$OAUTH_SRC" ]; then
  mkdir -p "$(dirname "$OAUTH_DST")"
  cp "$OAUTH_SRC" "$OAUTH_DST"
  echo "OAuth token restored from persistent volume."
fi

# Wait for config to be created (allows SSH in to write it)
if [ ! -f "$CONFIG" ]; then
  echo "No config.json found. Waiting for config at $CONFIG ..."
  echo "SSH in and create it, then the gateway will start automatically."
  while [ ! -f "$CONFIG" ]; do
    sleep 5
  done
  echo "Config found! Starting..."
fi

# Start the WhatsApp bridge only if enabled in config
if python3 -c "import json; c=json.load(open('$CONFIG')); exit(0 if c.get('channels',{}).get('whatsapp',{}).get('enabled') else 1)" 2>/dev/null; then
  echo "Starting WhatsApp bridge..."
  cd /app/bridge && node dist/index.js &
  BRIDGE_PID=$!
  sleep 2
else
  echo "WhatsApp bridge not enabled, skipping."
fi

# Auto-restart gateway on exit
while true; do
  echo "Starting nanobot gateway..."
  cd /app && nanobot gateway
  echo "Gateway exited. Restarting in 3 seconds..."
  sleep 3
done
