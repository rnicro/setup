#!/bin/sh

#pipewire >/dev/null 2>&1 &
#pipewire-pulse >/dev/null 2>&1 &
#wireplumber >/dev/null 2>&1 &
brightnessctl -q set 15%
exec dwl >/dev/null
