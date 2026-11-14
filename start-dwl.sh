#!/bin/sh

brightnessctl -q set 15% &
#exec dbus-run-session -- dwl -s 'exec pipewire >/dev/null 2>&1' >/dev/null
exec dwl >/dev/null
