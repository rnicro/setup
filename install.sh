#!/bin/sh

set -e

if [ "$(id -u)" -eq 0 ]; then
    echo "Do not run this script as root."
    exit 1
fi

nul="> /dev/null"

echo "Installing base packages"
sudo xbps-install -Sy void-repo-nonfree
sudo xbps-install -Sy intel-ucode
sudo xbps-reconfigure -f "linux$(uname -r | cut -d. -f1-2)"
sudo xbps-install -Sy foot tofi pipewire wireplumber brightnessctl vim zathura-pdf-mupdf yazi wlsunset elogind \
    grim libspa-bluetooth bluez polkit aria2 mesa-dri mesa-vulkan-intel vulkan-loader intel-media-driver tlp wlroots0.20-devel \
    make pkg-config gcc noto-fonts-ttf

cd "$HOME"

echo "Creating user directories"
mkdir -p .config/tofi .config/foot .config/velotype
mkdir Downloads Notes Pictures

rnicro=https://github.com/rnicro/setup/raw/refs/heads/main
aria="aria2c -x16 -s16 -k1M"

echo "Downloading configuration files and dotfiles"
$aria "$rnicro/config" -d .config/tofi
$aria "$rnicro/tofi-status.sh" -d .config/tofi
$aria "$rnicro/foot.ini" -d .config/foot
$aria "$rnicro/.history" -d .config/velotype
$aria "$rnicro/config.toml" -d .config/velotype
sudo rm -f /etc/default/grub
sudo $aria "$rnicro/grub" -d /etc/defualt
sudo update-grub
$aria "$rnicro/dwl.tar"
$aria "$rnicro/bookmarks.html"
$aria "$rnicro/start-dwl.sh"
$aria --allow-overwrite=true "$rnicro/.bash_profile"
$aria --allow-overwrite=true "$rnicro/.bashrc"
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
    echo "Downloading Linux kernel"
    $aria https://github.com/rnicro/kernel/releases/download/kernel-7.3.0_1/linux7.3-7.3.0_1.x86_64-musl.xbps
    $aria https://github.com/rnicro/kernel/releases/download/kernel-7.3.0_1/linux7.3-headers-7.3.0_1.x86_64-musl.xbps
    echo "Downloading Velotype"
    $aria https://github.com/rnicro/velotype/releases/download/0.7.8/velotype-0.7.8_1.x86_64-musl.xbps
    echo "Downloading LibreWolf"
    $aria https://github.com/rnicro/librewolf/releases/download/160.0-r1/librewolf-160.0_1.x86_64-musl.xbps

else
    echo "glibc detected"
    sudo xbps-install -Sy binutils curl xz
    mkdir -p xdeb
    $aria https://github.com/xdeb-org/xdeb/raw/refs/heads/master/xdeb -d xdeb/
    chmod +x xdeb/xdeb

    echo "Downloading helium browser"
    $aria https://github.com/imputnet/helium-linux/releases/download/0.22.0.1/helium-bin_0.22.0.1-1_amd64.deb
fi

cd "$HOME"

echo "Enabling selected services"
sudo ln -s /etc/sv/tlp /var/service/tlp
sudo ln -s /etc/sv/dbus /var/service/dbus
sudo ln -s /etc/sv/elogind /var/service/elogind
sudo ln -s /etc/sv/bluetoothd /var/service

sudo usermod -aG bluetooth $USER

echo "Removing unused services"
cd /var/service
sudo rm -f agetty-tty3
sudo rm -f agetty-tty4
sudo rm -f agetty-tty5
sudo rm -f agetty-tty6

cd $HOME

echo "Writing the post-install checklist"
$aria "$rnicro/todo"

echo "Setup complete. Review ~/todo for remaining tasks."
