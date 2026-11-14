#!/bin/sh

set -e

#commented lines mean they are under-development

if [ "$(id -u)" -eq 0 ]; then
    echo "Do not run this script as root."
    exit 1
fi

echo "Installing base packages"
sudo xbps-install -Sy void-repo-nonfree
sudo xbps-install -Sy intel-ucode
sudo xbps-reconfigure -f "linux$(uname -r | cut -d. -f1-2)"
sudo xbps-install -Sy foot tofi pipewire wireplumber brightnessctl vim \
    zathura-pdf-mupdf yazi wlsunset elogind grim libspa-bluetooth bluez \
    polkit aria2 mesa-dri mesa-vulkan-intel vulkan-loader intel-media-driver \
    tlp wlroots0.20-devel make pkg-config gcc noto-fonts-ttf

cd "$HOME"

echo "Creating user directories"
mkdir -p .config/tofi .config/foot .config/velotype
mkdir -p Downloads Notes Pictures
mkdir -p ~/.config/pipewire/pipewire.conf.d
ln -sf /usr/share/examples/wireplumber/10-wireplumber.conf ~/.config/pipewire/pipewire.conf.d/
ln -sf /usr/share/examples/pipewire/20-pipewire-pulse.conf ~/.config/pipewire/pipewire.conf.d/

rnicro=https://github.com/rnicro/setup/raw/refs/heads/main

echo "Downloading configuration files and dotfiles"
aria2c "$rnicro/config" -d .config/tofi
aria2c "$rnicro/tofi-status.sh" -d .config/tofi
aria2c "$rnicro/foot.ini" -d .config/foot
aria2c "$rnicro/.history" -d .config/velotype
aria2c "$rnicro/config.toml" -d .config/velotype
aria2c "$rnicro/dwl.tar"
aria2c "$rnicro/bookmarks.html"
aria2c "$rnicro/start-dwl.sh"
aria2c --allow-overwrite=true "$rnicro/.bash_profile"
aria2c --allow-overwrite=true "$rnicro/.bashrc"
chmod +x .config/tofi/tofi-status.sh
chmod +x start-dwl.sh

echo "Extracting and configuring dwl"
tar xf dwl.tar
rm dwl.tar
cd dwl
rm -f config.h
make clean
make
sudo make install

cd "$HOME"

echo "Downloading optional software"
if ldd --version 2>&1 | grep -qi musl; then

    echo "musl detected"
    echo "Downloading the custom Linux kernel"
    aria2c -x16 -s16 -k1M https://github.com/rnicro/kernel/releases/download/kernel-7.3.0_1/linux7.3-7.3.0_1.x86_64-musl.xbps
    aria2c -x16 -s16 -k1M https://github.com/rnicro/kernel/releases/download/kernel-7.3.0_1/linux7.3-headers-7.3.0_1.x86_64-musl.xbps
    echo "Downloading Velotype"
    aria2c -x16 -s16 -k1m https://github.com/rnicro/velotype/releases/download/0.7.8/velotype-0.7.8_1.x86_64-musl.xbps
    echo "Downloading LibreWolf"
    aria2c -x16 -s16 -k1m https://github.com/rnicro/librewolf/releases/download/159.0-r4/librewolf-159.0_4.x86_64-musl.xbps

#else
#
#    echo "glibc detected; preparing xdeb"
#    sudo xbps-install -Sy binutils curl xz
#
#    mkdir -p xdeb
#    aria2c https://github.com/xdeb-org/xdeb/raw/refs/heads/master/xdeb -d xdeb/
#    chmod +x xdeb/xdeb
#
#    printf 'Install browser? [y/N] '
#    IFS= read -r browser
#
#    if [ "$browser" = y ]; then
#
#        printf 'Which browser (brave/helium)? '
#        IFS= read -r browser_choice
#
#        if [ "$browser_choice" = brave ]; then
#
#            printf 'Brave version: '
#            IFS= read -r ver_brave
#
#            cd xdeb
#
#            aria2c -x16 -s16 -k1M \
#                "https://github.com/brave/brave-browser/releases/download/v${ver_brave}/brave-origin_${ver_brave}_amd64.deb"
#
#            ./xdeb -Sed "brave-origin_${ver_brave}_amd64.deb"
#
#        elif [ "$browser_choice" = helium ]; then
#            echo "Helium installation is not implemented yet."
#        fi
#    fi
#fi

cd "$HOME"

echo "Enabling selected services"
sudo ln -sfn /etc/sv/tlp /var/service/tlp
sudo ln -sfn /etc/sv/dbus /var/service/dbus
sudo ln -sfn /etc/sv/elogind /var/service/elogind

echo "Removing unused services"
sudo rm -f /var/service/agetty-tty[3-6]

echo "Configuring GRUB"
printf '%s\n' \
    "GRUB_DEFAULT=0" \
    "GRUB_TIMEOUT=0" \
    'GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3"' |
    sudo tee /etc/default/grub

sudo update-grub

echo "Writing the post-install checklist"
printf '%s\n' \
    "download a browser" \
    "download velotype + kernel, and gpu drivers if i bothered to optimize" \
    "change /etc/fstab" \
    "remove unnecessary services /var/service" \
    "may remove void-repo-nonfree, but can't get updates" \
    'change theme>body+interface font to "Noto Sans" in velotype and code to monospace' \
    "remove todo after setup" > todo

echo "Setup complete. Review ~/todo for remaining tasks."
