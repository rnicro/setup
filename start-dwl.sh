#!/bin/sh

exec dbus-run-session dwl >/dev/null
brightnessctl -q set 15%
pipewire >/dev/null &
#pipewire-pulse >/dev/null &
wireplumber >/dev/null &
