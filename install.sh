#!/bin/sh

#commented lines mean that they are under development

set -e

if [ "$(id -u)" -eq 0 ]; then
    echo "Do not run this script as root."
    exit 1
fi

sudo xbps-install -Sy void-repo-nonfree
sudo xbps-install -Sy intel-ucode
sudo xbps-reconfigure -fa

sudo xbps-install -Sy foot tofi pipewire wireplumber brightnessctl vim zathura-pdf-mupdf yazi wlsunset elogind grim alsa-pipewire libspa-bluetooth bluez polkit mesa-dri mesa-vulkan-intel vulkan-loader intel-media-driver tlp wlroots0.20-devel make pkg-config gcc aria2

cd "$HOME" || exit 1

mkdir -p .config/tofi .config/foot .config/velotype
mkdir -p Downloads Notes Pictures

aria2c --allow-overwrite=true --auto-file-renaming=false https://github.com/rnicro/setup/raw/refs/heads/main/config -d .config/tofi
aria2c --allow-overwrite=true --auto-file-renaming=false https://github.com/rnicro/setup/raw/refs/heads/main/tofi-status.sh -d .config/tofi
aria2c --allow-overwrite=true --auto-file-renaming=false https://github.com/rnicro/setup/raw/refs/heads/main/foot.ini -d .config/foot
aria2c --allow-overwrite=true --auto-file-renaming=false https://github.com/rnicro/setup/raw/refs/heads/main/.history -d .config/velotype
aria2c --allow-overwrite=true --auto-file-renaming=false https://github.com/rnicro/setup/raw/refs/heads/main/config.toml -d .config/velotype

aria2c --allow-overwrite=true --auto-file-renaming=false https://github.com/rnicro/setup/raw/refs/heads/main/.bash_profile
aria2c --allow-overwrite=true --auto-file-renaming=false https://github.com/rnicro/setup/raw/refs/heads/main/.bashrc
aria2c --allow-overwrite=true --auto-file-renaming=false https://github.com/rnicro/setup/raw/refs/heads/main/start-dwl.sh
chmod +x start-dwl.sh
aria2c --allow-overwrite=true --auto-file-renaming=false https://github.com/rnicro/setup/raw/refs/heads/main/dwl.tar
#aria2c --allow-overwrite=true --auto-file-renaming=false https://github.com/rnicro/setup/raw/refs/heads/main/bookmark.html

tar xf dwl.tar
rm dwl.tar

#if ldd --version 2>&1 | grep -qi musl; then
#	#ask for kernel, velotype, meh gpu drivers
#	read -n 1 -p "install linux kernel (y/n): " kernel
#	if $kernel == y; then
#		echo "installing linux kernel"
#		aria2c -x16 -s16 -k1m https://github.com/rnicro/kernel/releases/download/kernel-7.3.0_1/linux7.3-7.3.0_1.x86_64-musl.xbps
#		https://github.com/rnicro/kernel/releases/download/kernel-7.3.0_1/linux7.3-headers-7.3.0_1.x86_64-musl.xbps
#	read -n 1 -p "install velotype (y/n): " velotype
#	if $velotype == y; then
#		echo "installing velotype"
#		aria2c -x16 -s16 -k1m https://github.com/rnicro/velotype/releases/download/0.7.8/velotype-0.7.8_1.x86_64-musl.xbps
#	read -n 1 -p "install velotype (y/n): " velotype
#	if $velotype == y; then
#		echo "installing velotype"
#		aria2c -x16 -s16 -k1m https://github.com/rnicro/librewolf/releases/download/159.0-r4/librewolf-159.0_4.x86_64-musl.xbps
#
#else
#	mkdir xdeb
#	aria2c https://github.com/xdeb-org/xdeb/raw/refs/heads/master/xdeb -d xdeb/
#	chmod +x xdeb/xdeb
#
#	#choice for browser
#fi 

sudo ln -s /etc/sv/tlp /var/service
sudo ln -s /etc/sv/dbus /var/service
sudo ln -s /etc/sv/elogind /var/service

#pending to add notes md

printf '%s\n' \
    "GRUB_DEFAULT=0" \ 
    "GRUB_TIMEOUT=0" \
    'GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3"' | sudo tee /etc/default/grub
sudo update-grub

printf '%s\n' \
    "download a browser" \
    "download velotype + kernel, and gpu drivers if i bothered to optimize" \
    "change /etc/fstab" \
    "remove unnecessary services /var/service" \
    "may remove void-repo-nonfree, but can't get updates" \
    'change theme>body+interface font to "Noto Sans" in velotype and code to monospace' \
    "this mght help - https://github.com/xdeb-org/xdeb/raw/refs/heads/master/xdeb and https://github.com/rnicro/librewolf/releases/download/159.0-r4/librewolf-159.0_4.x86_64-musl.xbps and https://github.com/rnicro/velotype/releases/download/0.7.8/velotype-0.7.8_1.x86_64-musl.xbps and https://github.com/rnicro/kernel/releases/download/kernel-7.3.0_1/linux7.3-7.3.0_1.x86_64-musl.xbps and https://github.com/rnicro/kernel/releases/download/kernel-7.3.0_1/linux7.3-headers-7.3.0_1.x86_64-musl.xbps" \
    "remove todo after setup" > todo
