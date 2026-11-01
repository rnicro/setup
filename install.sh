#!/bin/sh
set -e

if [ "$(id -u)" -eq 0 ]; then
    echo "Do not run this script as root."
    exit 1
fi

sudo xbps-install -Sy void-repo-nonfree
sudo xbps-install -Sy intel-ucode
sudo xbps-reconfigure -fa

# may remove void-repo-nonfree, but can't get updates

sudo xbps-install -Sy foot tofi pipewire wireplumber brightnessctl vim zathura-pdf-mupdf yazi wlsunset elogind grim alsa-pipewire libspa-bluetooth bluez polkit mesa-dri mesa-vulkan-intel vulkan-loader intel-media-driver tlp wlroots0.20-devel make pkg-config gcc aria2

cd "$HOME" || exit 1

rm -rf .config/tofi .config/foot .config/velotype dwl
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
aria2c --allow-overwrite=true --auto-file-renaming=false https://github.com/rnicro/setup/raw/refs/heads/main/dwl.tar

tar xf dwl.tar
rm dwl.tar

printf '%s\n' \
    "download a browser (brave origin, librewolf or helium)" \
    "download velotype" \
    "change /etc/fstab" \
    "set GRUB" \
    "remove unnecessary services /var/service" \
    "link services" \
    'change theme>body+interface font to "Noto Sans" in velotype and code to monospace' \
    "this mght help - https://github.com/xdeb-org/xdeb/raw/refs/heads/master/xdeb and https://github.com/rnicro/librewolf/releases/download/...lastest" \
    "remove todo after setup" > todo
