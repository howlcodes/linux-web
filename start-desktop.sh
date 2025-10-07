#!/usr/bin/env bash
export DISPLAY=:99
export HOME=/home/user
mkdir -p /home/user/.vnc
chown -R user:user /home/user

# Start dbus
dbus-uuidgen > /var/lib/dbus/machine-id || true
dbus-launch --exit-with-session bash -lc "
  # Start X virtual framebuffer
  Xvfb :99 -screen 0 1280x800x24 &

  # PulseAudio (user)
  pulseaudio --start || true

  # Start XFCE session
  /usr/bin/startxfce4 &

  # Wait a bit for X to be up
  sleep 3

  # Start x11vnc to share the display
  nohup x11vnc -display :99 -nopw -listen 0.0.0.0 -forever -shared -rfbport 5900 >/var/log/x11vnc.log 2>&1 &

  # Start websockify (noVNC's wrapper)
  cd /opt/noVNC/utils
  nohup python3 websockify --web=/opt/noVNC --cert= self 8080 localhost:5900 >/var/log/websockify.log 2>&1 &

  # Keep the dbus shell open
  tail -f /dev/null
"
