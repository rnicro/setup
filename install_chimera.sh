
#!/bin/sh

set -eu

if [ "$(id -u)" -eq 0 ]; then
    echo "Do not run this script as root."
    exit 1
fi

if command -v doas >/dev/null 2>&1; then
    ROOT="doas"
elif command -v sudo >/dev/null 2>&1; then
    ROOT="sudo"
else
    echo "Install doas or sudo first."
    exit 1
fi

as_root() {
    "$ROOT" "$@"
}

echo "Updating Chimera Linux"
as_root apk update
as_root apk upgrade --available

echo "Installing packages"

as_root apk add \
    curl aria2 \
    foot tofi pipewire wireplumber \
    brightnessctl vim \
    zathura-pdf-mupdf yazi wlsunset grim \
    bluez polkit tlp elogind \
    mesa-dri mesa-vulkan-intel vulkan-loader \
    intel-media-driver intel-ucode \
    make gcc pkgconf \
    wlroots-devel wayland-devel wayland-protocols \
    libinput-devel libxkbcommon-devel pixman-devel \
    libdrm-devel fcft-devel noto-fonts

echo "Creating user directories"

mkdir -p \
    "$HOME/.config/foot" \
    "$HOME/.config/tofi" \
    "$HOME/.config/velotype" \
    "$HOME/Downloads" \
    "$HOME/Notes" \
    "$HOME/Pictures"

rnicro="https://github.com/rnicro/setup/raw/refs/heads/main/HOME"

download() {
    curl -fL --retry 3 "$1" -o "$2"
}

echo "Downloading dotfiles"

download "$rnicro/.bash_profile" "$HOME/.bash_profile"
download "$rnicro/.bashrc" "$HOME/.bashrc"

download "$rnicro/.config/foot/foot.ini" \
    "$HOME/.config/foot/foot.ini"

download "$rnicro/.config/tofi/config" \
    "$HOME/.config/tofi/config"

download "$rnicro/.config/tofi/tofi-status.sh" \
    "$HOME/.config/tofi/tofi-status.sh"

download "$rnicro/.config/velotype/config.toml" \
    "$HOME/.config/velotype/config.toml"

download "$rnicro/bookmark.html" "$HOME/bookmark.html"
download "$rnicro/todo" "$HOME/todo"
download "$rnicro/dwl.tar" "$HOME/dwl.tar"

chmod +x "$HOME/.config/tofi/tofi-status.sh"

echo "Creating Chimera-compatible dwl launcher"

cat > "$HOME/start-dwl.sh" <<'EOF'
#!/bin/sh
brightnessctl -q set 20% || :
exec dwl
EOF

chmod +x "$HOME/start-dwl.sh"

echo "Building dwl"

cd "$HOME"
tar -xf dwl.tar
cd "$HOME/dwl"

make clean
make
as_root make install

cd "$HOME"
rm -f dwl.tar

echo "Dinit services"
echo "Check available services with: dinitctl list"
echo "Enable the services you need with: doas dinitctl enable SERVICE"

echo "Setup complete. Review ~/todo for remaining tasks."
