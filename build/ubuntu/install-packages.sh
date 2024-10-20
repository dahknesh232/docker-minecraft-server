#!/bin/bash

export TARGET

set -euo pipefail

# Update, Upgrade, and install packages
apt-get update

apt-get upgrade -y

# shellcheck disable=SC2086
DEBIAN_FRONTEND=noninteractive \
apt-get install -y \
  imagemagick \
  file \
  sudo \
  net-tools \
  iputils-ping \
  curl \
  git \
  jq \
  dos2unix \
  mysql-client \
  tzdata \
  rsync \
  nano \
  unzip \
  zstd \
  lbzip2 \
  nfs-common \
  libpcap0.8 \
  ${EXTRA_DEB_PACKAGES}

# Install Git LFS
curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | sudo bash
apt-get update
apt-get install -y git-lfs

# Clean up APT when done
apt-get clean

#Remove existing Go and install patched version
apt remove golang golang-go
rm -rf /usr/local/go
curl -fsSL -o /tmp/go.tar.gz https://go.dev/dl/go1.23.2.linux-amd64.tar.gz
tar -xf /tmp/go.tar.gz -C /usr/local/ && rm /tmp/go.tar.gz

# Install patched gosu
curl -fsSL -o /tmp/gosu https://github.com/tianon/gosu/releases/download/1.17/gosu-amd64
curl -fsSL -o /tmp/gosu.asc https://github.com/tianon/gosu/releases/download/1.17/gosu-amd64.asc
chmod +x /tmp/gosu
cp /tmp/gosu.asc /usr/local/ && rm /tmp/gosu.asc
cp /tmp/gosu /usr/local/ && rm /tmp/gosu
chmod +x /usr/local/gosu
ln -s /usr/local/gosu /usr/sbin/gosu
ln -s /usr/local/gosu /usr/local/sbin/gosu


# Download and install patched knockd
curl -fsSL -o /tmp/knock.tar.gz https://github.com/Metalcape/knock/releases/download/0.8.1/knock-0.8.1-$TARGET.tar.gz
tar -xf /tmp/knock.tar.gz -C /usr/local/ && rm /tmp/knock.tar.gz
ln -s /usr/local/sbin/knockd /usr/sbin/knockd
setcap cap_net_raw=ep /usr/local/sbin/knockd
find /usr/lib -name 'libpcap.so.0.8' -execdir cp '{}' libpcap.so.1 \;

# Set git credentials globally
cat <<EOF >> /etc/gitconfig
[user]
	name = Minecraft Server on Docker
	email = server@example.com
EOF
