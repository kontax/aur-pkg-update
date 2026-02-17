FROM archlinux:base

# Set up base files
COPY sudoers /etc/sudoers
COPY mirrorlist /etc/pacman.d/mirrorlist

# Update keychain
RUN pacman-key --init && \
    pacman-key --populate && \
    pacman -Sy --noconfirm archlinux-keyring

# Install base packages
RUN pacman -Syu --noconfirm --needed \
    base-devel \
    git \
    devtools \
    aws-cli \
    jq \
    python-setuptools \
    mkinitcpio

# Non-root user used to build packages
RUN useradd -d /build makepkg && mkdir /build && chown -R makepkg:users /build

# --- FIX: Add Perl locations to PATH so pod2man can be found ---
ENV PATH="/usr/bin/core_perl:${PATH}"

# Make xz compression use all available cores
RUN sed -E -i \
    's/COMPRESSXZ.*/COMPRESSXZ=(xz -c -z - --threads=0)/g; \
     s/(#)?MAKEFLAGS.*/MAKEFLAGS="-j$(nproc)"/g' /etc/makepkg.conf

# 1. Pull and compile pacutils-git from AUR (Bypasses broken upstream package)
RUN sudo -u makepkg git clone --depth 1 https://aur.archlinux.org/pacutils-git.git /build/pacutils-git && \
    cd /build/pacutils-git && \
    sudo -u makepkg makepkg --noconfirm -sif --nocheck

# 2. Pull aurutils from AUR (Will use our fixed pacutils)
RUN sudo -u makepkg git clone --depth 1 https://aur.archlinux.org/aurutils.git /build/aurutils && \
    cd /build/aurutils && \
    sudo -u makepkg makepkg --noconfirm -sif --nocheck

# Scripts
ADD send-pushover /send-pushover
ADD aursync /aursync
ENTRYPOINT ["/aursync"]
#CMD ["/bin/bash"]
