FROM archlinux:base

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

# Make xz compression use all available cores
RUN sed -E -i \
    's/COMPRESSXZ.*/COMPRESSXZ=(xz -c -z - --threads=0)/g; \
     s/(#)?MAKEFLAGS.*/MAKEFLAGS="-j$(nproc)"/g' /etc/makepkg.conf

# Pull aurutils from AUR
RUN sudo -u makepkg git clone --depth 1 https://aur.archlinux.org/aurutils.git /build
#RUN sudo -u makepkg gpg --keyserver hkp://keyserver.ubuntu.com --recv-keys 6BC26A17B9B7018A
RUN cd /build && sudo -u makepkg makepkg --noconfirm -sif

# Scripts
ADD send-pushover /send-pushover
ADD aursync /aursync
ENTRYPOINT ["/aursync"]
#CMD ["/bin/bash"]
