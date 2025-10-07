#!/usr/bin/env bash
export DISPLAY=:99
export HOME=/home/user

# Use the PORT environment variable provided by Render
PORT=${PORT:-8080}  # default to 8080 if not set

mkdir -p /home/user/.vnc
chown -R user:user /home/user

# Start dbus
dbus-uuidgen > /var/lib/dbus/machine-id || true

# Launch Xvfb, XFCE, x11vnc, and websockify
dbus-launch --exit-with-session bash -lc "
  Xvfb :99 -screen 0 1280x800x24 &
  pulseaudio --start || true
  /usr/bin/startxfce4 &
  sleep 3
  nohup x11vnc -display :99 -nopw -listen 0.0.0.0 -forever -shared -rfbport 5900 >/var/log/x11vnc.log 2>&1 &
  cd /opt/noVNC/utils
  nohup python3 websockify --web=/opt/noVNC \$PORT localhost:5900 >/var/log/websockify.log 2>&1 &
  tail -f /dev/null
"
