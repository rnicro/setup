#!/bin/sh

exec dbus-run-session dwl >/dev/null
brightnessctl -q set 15%
pipewire >/dev/null 2>&1 &
#pipewire-pulse >/dev/null 2>&1 &
wireplumber >/dev/null 2>&1 &
