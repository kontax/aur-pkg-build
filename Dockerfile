FROM archlinux/base:latest

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

# Make xz compression use all available cores
RUN sed -E -i \
    's/COMPRESSXZ.*/COMPRESSXZ=(xz -c -z - --threads=0)/g; \
     s/(#)?MAKEFLAGS.*/MAKEFLAGS="-j$(nproc)"/g' /etc/makepkg.conf

# Scripts
ADD scripts/build-aur       /build-aur
ADD scripts/build-git       /build-git
ADD scripts/build-pkgbuild  /build-pkgbuild
ADD scripts/send-pushover   /send-pushover
ADD scripts/pull-queue      /pull-queue
ADD scripts/reset           /reset
ENTRYPOINT ["/pull-queue"]
