#!/bin/sh

#pipewire 2>&1 &
#pipewire-pulse 2>&1 &
#wireplumber 2>&1 &
brightnessctl -q set 20%
#exec dbus-run-session dwl
exec dwl
