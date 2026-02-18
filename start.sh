#!/bin/sh
# Start WhatsApp bridge (Node.js) in the background, then run nanobot gateway.

CONFIG="/root/.nanobot/config.json"

# Wait for config to be created (allows SSH in to write it)
if [ ! -f "$CONFIG" ]; then
  echo "No config.json found. Waiting for config at $CONFIG ..."
  echo "SSH in and create it, then the gateway will start automatically."
  while [ ! -f "$CONFIG" ]; do
    sleep 5
  done
  echo "Config found! Starting..."
fi

# Start the WhatsApp bridge
echo "Starting WhatsApp bridge..."
cd /app/bridge && node dist/index.js &
BRIDGE_PID=$!

# Give the bridge a moment to start
sleep 2

# Start the nanobot gateway
echo "Starting nanobot gateway..."
cd /app && nanobot gateway

# If gateway exits, also stop the bridge
kill $BRIDGE_PID 2>/dev/null
