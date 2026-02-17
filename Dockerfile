FROM archlinux:base

# Set up base files
COPY cfg/sudoers            /etc/sudoers
COPY cfg/mirrorlist         /etc/pacman.d/mirrorlist

# Install base packages
RUN pacman -Syu --noconfirm --needed \
    base-devel \
    git \
    devtools \
    aws-cli \
    jq

# Non-root user used to build packages
RUN mkdir /mphome \
    && useradd -d /mphome makepkg \
    && chown makepkg /mphome

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
ADD scripts/setup-repo              /setup-repo
ADD scripts/setup-signing-key       /setup-signing-key
ADD scripts/setup-verification-keys /setup-verification-keys
ADD scripts/build-repo              /build-repo
ADD scripts/build-aur               /build-aur
ADD scripts/build-git               /build-git
ADD scripts/send-pushover           /send-pushover
ADD scripts/pull-queue              /pull-queue
ADD scripts/reset                   /reset
ENTRYPOINT ["/pull-queue"]
#CMD ["/bin/bash"]
