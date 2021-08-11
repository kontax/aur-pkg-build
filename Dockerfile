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

# Make xz compression use all available cores
RUN sed -E -i \
    's/COMPRESSXZ.*/COMPRESSXZ=(xz -c -z - --threads=0)/g; \
     s/(#)?MAKEFLAGS.*/MAKEFLAGS="-j$(nproc)"/g' /etc/makepkg.conf

# Pull aurutils from AUR
RUN sudo -u makepkg git clone --depth 1 https://aur.archlinux.org/aurutils.git /mphome
RUN sudo -u makepkg gpg --recv-keys 6BC26A17B9B7018A 
RUN cd /mphome && sudo -u makepkg makepkg --noconfirm -sif

# Scripts
ADD scripts/setup-repo          /setup-repo
ADD scripts/setup-signing-key   /setup-signing-key
ADD scripts/build-repo          /build-repo
ADD scripts/build-aur           /build-aur
ADD scripts/build-git           /build-git
ADD scripts/send-pushover       /send-pushover
ADD scripts/pull-queue          /pull-queue
ADD scripts/reset               /reset
ENTRYPOINT ["/pull-queue"]
#CMD ["/bin/bash"]
