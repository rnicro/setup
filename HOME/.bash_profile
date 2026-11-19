[ "$(tty)" = "/dev/tty1" ] && exec "$HOME/start-dwl.sh" >/dev/null
[ -f "$HOME/.bashrc" ] && . "$HOME/.bashrc"
