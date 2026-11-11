#!/bin/sh

exec dbus-run-session sh -c '
  brightnessctl -q set 15%
#  pipewire >/dev/null 2>&1 &
#  pipewire-pulse >/dev/null &
#  wireplumber >/dev/null 2>&1 &
  exec dwl >/dev/null
'
