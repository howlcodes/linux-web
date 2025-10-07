# Dockerfile for Howl-Desktop (Ubuntu 22.04 XFCE + noVNC + Prism Launcher + Flatpak + Zen)
FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8 \
    DISPLAY=:99 \
    NOVNC_PORT=8080

# Install basics
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates curl wget gnupg2 lsb-release sudo locales \
    xfce4 xfce4-goodies xorg x11vnc xvfb dbus-x11 \
    supervisor python3 python3-pip git \
    pulseaudio-utils pulseaudio \
    mesa-utils x11-xserver-utils \
    openjdk-17-jre-headless tzdata \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install websockify and noVNC
RUN git clone --depth 1 https://github.com/novnc/noVNC.git /opt/noVNC \
 && git clone --depth 1 https://github.com/novnc/websockify /opt/noVNC/utils/websockify

# Install flatpak and enable Flathub
RUN apt-get update && apt-get install -y flatpak software-properties-common \
 && flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo \
 && rm -rf /var/lib/apt/lists/*

# Add a user for the desktop
RUN useradd -ms /bin/bash user && echo "user ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/user-nopasswd

USER user
WORKDIR /home/user

# Install Prism Launcher and Zen Browser via Flatpak (noninteractive)
# Note: flatpak requires a dbus session; we'll install the apps into the system user flatpak config
RUN flatpak install -y --user flathub org.prismlauncher.PrismLauncher || true
RUN flatpak install -y --user flathub app.zen_browser.zen || true

# Expose the noVNC port
EXPOSE 8080

# Add startup script and supervisor config
USER root
COPY ./start-desktop.sh /usr/local/bin/start-desktop.sh
RUN chmod +x /usr/local/bin/start-desktop.sh

# Supervisor: start Xvfb, dbus, XFCE session, x11vnc & noVNC
COPY ./supervisord.conf /etc/supervisor/conf.d/supervisord.conf

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
