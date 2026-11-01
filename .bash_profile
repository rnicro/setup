[ -f $HOME/.bashrc ] && . $HOME/.bashrc
[ "$(tty)" = "/dev/tty1" ] && exec "$HOME/start-dwl.sh"
