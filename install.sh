#!/bin/sh

set -e

if [ "$(id -u)" -eq 0 ]; then
    echo "Do not run this script as root."
    exit 1
fi

echo "Installing base packages"
sudo xbps-install -Sy void-repo-nonfree
sudo xbps-install -Sy foot tofi pipewire wireplumber brightnessctl vim zathura-pdf-mupdf yazi wlsunset elogind \
    grim libspa-bluetooth bluez polkit aria2 mesa-dri mesa-vulkan-intel vulkan-loader intel-media-driver tlp wlroots0.20-devel \
    make pkg-config gcc noto-fonts-ttf intel-ucode

sudo xbps-reconfigure -f "linux$(uname -r | cut -d. -f1-2)"

cd "$HOME"

echo "Creating user directories"
mkdir -p .config/tofi .config/foot .config/velotype
mkdir -p Downloads Notes Pictures

rnicro=https://github.com/rnicro/setup/raw/refs/heads/main/HOME

download() {
    aria2c -x16 -s16 -k1M --allow-overwrite=true "$1" -d "$2"
}

echo "Downloading configuration files and dotfiles"

download "$rnicro/.bash_profile" "$HOME"
download "$rnicro/.bashrc" "$HOME"

download "$rnicro/.config/foot/foot.ini" "$HOME/.config/foot"
download "$rnicro/.config/tofi/config" "$HOME/.config/tofi"
download "$rnicro/.config/tofi/tofi-status.sh" "$HOME/.config/tofi"
download "$rnicro/.config/velotype/config.toml" "$HOME/.config/velotype"

download "$rnicro/start-dwl.sh" "$HOME"
download "$rnicro/bookmarks.html" "$HOME"
download "$rnicro/todo" "$HOME"
download "$rnicro/dwl.tar" "$HOME"

chmod +x .config/tofi/tofi-status.sh
chmod +x start-dwl.sh

echo "Extracting and configuring dwl"
tar xf dwl.tar
rm dwl.tar

cd dwl
make
sudo make install
make clean
rm config.h

cd "$HOME"

echo "Downloading optional software"

if ldd --version 2>&1 | grep -qi musl; then

    echo "musl detected"

    download https://github.com/rnicro/linux/releases/download/7.3.5_1/linux7.3-7.3.5_1.x86_64-musl.xbps "$HOME"
    download https://github.com/rnicro/linux/releases/download/7.3.5_1/linux7.3-headers-7.3.5_1.x86_64-musl.xbps "$HOME"

    download https://github.com/rnicro/velotype/releases/download/0.7.8/velotype-0.7.8_1.x86_64-musl.xbps "$HOME"

    download https://github.com/rnicro/Monorepo/releases/download/xbps-repository/librewolf-161.0_7.x86_64-musl.xbps "$HOME"

    download https://github.com/rnicro/Monorepo/releases/download/xbps-repository/wlsunset-0.4.0_2.x86_64-musl.xbps "$HOME"

    download https://github.com/rnicro/brightnessctl/releases/download/0.5.1_2/brightnessctl-0.5.1_2.x86_64-musl.xbps "$HOME"

    download https://github.com/rnicro/tofi/releases/download/0.9.1_2/tofi-0.9.1_2.x86_64-musl.xbps "$HOME"

    download https://github.com/rnicro/aria2/releases/download/1.37.0_3/aria2-1.37.0_3.x86_64-musl.xbps "$HOME"

else

    echo "glibc detected"

    sudo xbps-install -Sy binutils curl xz

    mkdir -p xdeb

    download https://github.com/xdeb-org/xdeb/raw/refs/heads/master/xdeb "$HOME/xdeb"
    chmod +x xdeb/xdeb

    echo "Downloading helium browser"
    download https://github.com/imputnet/helium-linux/releases/download/0.22.0.1/helium-bin_0.22.0.1-1_amd64.deb "$HOME"

fi

cd "$HOME"

echo "Enabling selected services"

sudo ln -s /etc/sv/tlp /var/service/tlp
sudo ln -s /etc/sv/dbus /var/service/dbus
sudo ln -s /etc/sv/elogind /var/service/elogind
#sudo ln -s /etc/sv/bluetoothd /var/service

sudo usermod -aG bluetooth "$USER"

echo "Removing unused services"

cd /var/service

sudo rm -f agetty-tty3
sudo rm -f agetty-tty4
sudo rm -f agetty-tty5
sudo rm -f agetty-tty6

cd "$HOME"

echo "Setup complete. Review ~/todo for remaining tasks."
