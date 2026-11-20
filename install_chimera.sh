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

echo "Enabling user repo and updating Chimera Linux"
as_root apk add chimera-repo-user
as_root apk update
as_root apk upgrade --available

echo "Installing packages"
# Note: Adjust wlroots0.19-devel to match your dwl version (0.18 / 0.19 / 0.20).
# Note: Verify 'tlp', 'tofi', 'wlsunset', etc. exist in repos, or swap tlp for power-profiles-daemon.
as_root apk add \
    bash curl aria2 \
    foot tofi pipewire wireplumber \
    brightnessctl vim \
    zathura zathura-pdf-mupdf yazi wlsunset grim \
    bluez polkit elogind power-profiles-daemon \
    mesa-dri mesa-vulkan vulkan-loader \
    intel-media-driver ucode-intel \
    gmake clang pkgconf \
    wlroots0.19-devel wayland-devel wayland-progs wayland-protocols \
    libinput-devel libxkbcommon-devel pixman-devel \
    libdrm-devel fcft-devel fonts-noto

echo "Refreshing initramfs for ucode-intel"
as_root update-initramfs -c -k all

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
download "$rnicro/.config/foot/foot.ini" "$HOME/.config/foot/foot.ini"
download "$rnicro/.config/tofi/config" "$HOME/.config/tofi/config"
download "$rnicro/.config/tofi/tofi-status.sh" "$HOME/.config/tofi/tofi-status.sh"
download "$rnicro/.config/velotype/config.toml" "$HOME/.config/velotype/config.toml"
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

gmake CC=clang clean
gmake CC=clang
as_root gmake install

cd "$HOME"
rm -f dwl.tar

echo "Dinit services:"
echo "  Running services:   dinitctl list"
echo "  Available services: ls /usr/lib/dinit.d /etc/dinit.d"
echo "  Enable a service:   doas dinitctl enable bluetoothd"
echo "  If using .bashrc:   chsh -s /usr/bin/bash"
echo "Setup complete. Review ~/todo for remaining tasks."
