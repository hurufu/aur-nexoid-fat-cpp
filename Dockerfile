FROM archlinux AS base

# Configuration
ARG DOCKER_USER=buildbot
ARG DOCKER_HOME=/home/$DOCKER_USER
ARG DOCKER_WORKDIR=$DOCKER_HOME/nexoid-fat-cpp-git

# Preparation
RUN pacman -Syu --asdeps --noconfirm --needed base-devel git cmake pkg-config

RUN useradd --base-dir /home -m --shell /bin/bash -g root --comment "Build Bot,,,," "$DOCKER_USER"
RUN echo '%root ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/root

# Configure makepkg
COPY makepkg.patch ./
RUN patch /etc/makepkg.conf makepkg.patch

USER "$DOCKER_USER"

RUN git clone https://aur.archlinux.org/auracle-git.git "$DOCKER_HOME/auracle-git" && \
    cd "$DOCKER_HOME/auracle-git" && \
    makepkg --syncdeps --rmdeps --install --clean --asdeps --noconfirm

RUN git clone https://aur.archlinux.org/pacaur.git "$DOCKER_HOME/pacaur" && \
    cd "$DOCKER_HOME/pacaur" && \
    makepkg --syncdeps --rmdeps --install --clean --asdeps --noconfirm

# TODO: Remove the neeed of EDITOR
RUN sudo pacman -S --noconfirm --needed vi
RUN pacaur --aur-sync --asdeps --noedit --noconfirm asn1c-git
RUN pacaur --aur-sync --asdeps --noedit --noconfirm drakon-editor
# TODO: Remove libsocket as a mandatory dependency
RUN pacaur --aur-sync --asdeps --noedit --noconfirm libsocket-git
RUN sudo pacman -S --noconfirm ninja mbedtls asciidoctor
# In order to pass unit tests IPv6 should be enabled in /etc/docker/daemon.json
#{ "ipv6": true, "fixed-cidr-v6": "fe80::42:2eff:fe28:990a/64" }
#RUN pacaur --aur-sync --asdeps --noedit --noconfirm nng-git
RUN git clone https://aur.archlinux.org/nng-git.git "$DOCKER_HOME/nng-git"
COPY --chown="$DOCKER_USER:root" 001-nng-git-PKGBUILD.patch "$DOCKER_HOME/nng-git/"
WORKDIR $DOCKER_HOME/nng-git
RUN patch < 001-nng-git-PKGBUILD.patch && \
    makepkg --syncdeps --rmdeps --install --clean --asdeps --noconfirm --nocheck

RUN pacaur --aur-sync --asdeps --noedit --noconfirm nngpp-git --nocheck

# SSH Credentials
RUN sudo pacman -S --noconfirm openssh
COPY --chown="$DOCKER_USER:root" ./.ssh/* "${DOCKER_HOME}/.ssh/"

# Actual build
COPY --chown="$DOCKER_USER:root" ./PKGBUILD "$DOCKER_WORKDIR/"
WORKDIR "$DOCKER_WORKDIR"
RUN makepkg --syncdeps --rmdeps --install --noconfirm --needed

# Test
ENTRYPOINT ["/usr/bin/nexoid-cpp"]
