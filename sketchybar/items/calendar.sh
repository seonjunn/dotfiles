#!/bin/sh

sketchybar --add item     calendar right                    \
           --set calendar icon=cal                          \
                          icon.font="$FONT:FiraCode Nerd Font Mono:13.0"      \
                          icon.padding_right=3				\
                          label.font="$FONT:FiraCode Nerd Font Mono:13.0"      \
                          label.width=50                    \
                          label.align=right                 \
                          padding_left=5                 \
                          update_freq=30                    \
                          script="$PLUGIN_DIR/calendar.sh"  \
                          click_script="$PLUGIN_DIR/zen.sh" \
           --subscribe    calendar system_woke
