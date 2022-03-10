#!/usr/bin/env bash

yabai -m query --spaces | jq 'map(select(."has-focus" == true))'[0].index
