FROM archlinux/base:latest

# Set up base files
COPY sudoers /etc/sudoers
COPY mirrorlist /etc/pacman.d/mirrorlist

# Install base packages
RUN pacman -Syu --noconfirm --needed \
    base-devel \
    git \
    devtools \
    aws-cli

# Non-root user used to build packages
RUN useradd -d /build makepkg && mkdir /build && chown -R makepkg:users /build

# Pull aurutils from AUR
RUN sudo -u makepkg git clone --depth 1 https://aur.archlinux.org/aurutils.git /build
RUN cd /build && sudo -u makepkg makepkg --noconfirm -sif

# Scripts
ADD send-pushover /send-pushover
ADD aursync /aursync
ENTRYPOINT ["/aursync"]
