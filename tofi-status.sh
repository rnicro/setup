#!/bin/sh
v=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null)
case "$v" in
	*"[MUTED]"*) vol=muted ;;
	Volume:*) vol=$(printf '%s\n' "$v" | awk '{printf "%.0f%%",$2*100}') ;;
	*) vol=N/A ;;
esac
read -r bat </sys/class/power_supply/BAT0/capacity
exec tofi-drun --placeholder-text "$vol | $bat% | $(date '+%I:%M %p')"
