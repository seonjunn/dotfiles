#!/usr/bin/env bash

# Terminate already running bar instances
killall -q polybar

echo "---" | tee -a /tmp/polybar1.log /tmp/polybar2.log
#polybar bar1 2>&1 | tee -a /tmp/polybar1.log & disown
#polybar bar1 2>&1 | tee -a /tmp/polybar2.log & disown

if type "xrandr"; then
    for m in $(xrandr --query | grep " connected" | cut -d" " -f1); do
        MONITOR=$m polybar --reload bar1 &
    done
else
    polybar --reload bar1 &
fi
