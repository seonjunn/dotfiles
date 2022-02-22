#!/usr/bin/env bash

# Terminate already running bar instances
killall -q polybar

echo "---" | tee -a /tmp/polybarL.log /tmp/polybarR.log
polybar -c $HOME/.config/polybar/config.ini left 2>&1 | tee -a /tmp/polybarL.log & disown
polybar -c $HOME/.config/polybar/config.ini right 2>&1 | tee -a /tmp/polybarR.log & disown

