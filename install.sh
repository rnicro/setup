#!/bin/sh

set -e

echo "Checking user privileges"
if [ "$(id -u)" -eq 0 ]; then
    echo "Do not run this script as root."
    exit 1
fi

echo "Adding the nonfree repository and installing Intel microcode"
sudo xbps-install -Sy void-repo-nonfree
sudo xbps-install -Sy intel-ucode
sudo xbps-reconfigure -fa

echo "Installing base packages"
sudo xbps-install -Sy \
    foot tofi pipewire wireplumber brightnessctl vim \
    zathura-pdf-mupdf yazi wlsunset elogind grim \
    alsa-pipewire libspa-bluetooth bluez polkit aria2 \
    mesa-dri mesa-vulkan-intel vulkan-loader \
    intel-media-driver tlp wlroots0.20-devel \
    make pkg-config gcc

echo "Creating user directories"
cd "$HOME"

mkdir -p .config/tofi .config/foot .config/velotype
mkdir -p Downloads Notes Pictures

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
chmod +x start-dwl.sh

echo "Extracting dwl source"
tar xf dwl.tar
rm dwl.tar

echo "Configuring dwl"
cd dwl
sudo rm -f config.h
make clean
sudo make install

cd "$HOME"

echo "Detecting libc and configuring optional software"
if ldd --version 2>&1 | grep -qi musl; then

    echo "musl detected"
    printf 'Install Linux kernel? [y/N] '
    IFS= read -r kernel

    if [ "$kernel" = y ]; then
        echo "Downloading and installing the custom Linux kernel"
        aria2c -x16 -s16 -k1M \
            https://github.com/rnicro/kernel/releases/download/kernel-7.3.0_1/linux7.3-7.3.0_1.x86_64-musl.xbps

        aria2c -x16 -s16 -k1M \
            https://github.com/rnicro/kernel/releases/download/kernel-7.3.0_1/linux7.3-headers-7.3.0_1.x86_64-musl.xbps

        sudo xbps-install -R . linux7.3*
        rm -f linux7.3*
    fi

    printf 'Install Velotype? [y/N] '
    IFS= read -r velotype

    if [ "$velotype" = y ]; then
        echo "Downloading and installing Velotype"
        aria2c -x16 -s16 -k1m \
            https://github.com/rnicro/velotype/releases/download/0.7.8/velotype-0.7.8_1.x86_64-musl.xbps

        sudo xbps-install -R . velotype*
        rm -f velotype*
    fi

    printf 'Install LibreWolf? [y/N] '
    IFS= read -r librewolf

    if [ "$librewolf" = y ]; then
        echo "Downloading and installing LibreWolf"
        aria2c -x16 -s16 -k1m \
            https://github.com/rnicro/librewolf/releases/download/159.0-r4/librewolf-159.0_4.x86_64-musl.xbps

        sudo xbps-install -R . librewolf*
        rm -f librewolf*
    fi

else

    echo "glibc detected; preparing xdeb"
    sudo xbps-install -Sy binutils curl xz

    mkdir -p xdeb
    aria2c https://github.com/xdeb-org/xdeb/raw/refs/heads/master/xdeb -d xdeb/
    chmod +x xdeb/xdeb

    printf 'Install browser? [y/N] '
    IFS= read -r browser

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
fi

echo "Enabling selected services"
cd "$HOME"

sudo ln -sfn /etc/sv/tlp /var/service/tlp
sudo ln -sfn /etc/sv/dbus /var/service/dbus
sudo ln -sfn /etc/sv/elogind /var/service/elogind

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
