#!/bin/bash
set -e

USER="seonjunkim"
FILE="/etc/sudoers.d/${USER}"
LINE="${USER} ALL=(ALL) NOPASSWD: ALL"

# must be run as root
if [ "$(id -u)" -ne 0 ]; then
  echo "run as root"
  exit 1
fi

# write sudoers entry
echo "${LINE}" > "${FILE}"

# set correct permissions
chmod 0440 "${FILE}"

# validate sudoers syntax
visudo -cf "${FILE}"

# create directories
mkdir -p ~/bin
mkdir -p ~/projects
mkdir -p ~/docs
mkdir -p ~/opt
mkdir -p ~/etc
mkdir -p ~/tmp
