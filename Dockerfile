FROM archlinux/base:latest

# Set up base files
COPY sudoers /etc/sudoers
COPY mirrorlist /etc/pacman.d/mirrorlist

# Install base packages
RUN pacman -Syu --noconfirm --needed \
    base-devel \
    git \
    devtools \
    aws-cli \
    jq

# Non-root user used to build packages
RUN useradd -d /build makepkg

# Scripts
ADD build-aur /build-aur
ADD build-git /build-git
ADD build-pkgbuild /build-pkgbuild
ADD send-pushover /send-pushover
ADD pull-queue /pull-queue
ENTRYPOINT ["/pull-queue"]
