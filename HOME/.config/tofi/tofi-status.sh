#!/bin/sh
v=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null)
case "$v" in
	*"[MUTED]"*) vol=muted ;;
	Volume:*) vol=$(printf '%.0f%%' "${v#Volume: }e2") ;;
	*) vol=N/A ;;
esac
read -r bat </sys/class/power_supply/BAT0/capacity
exec tofi-drun --placeholder-text "$vol · $bat% · $(date '+%I:%M %p')"
