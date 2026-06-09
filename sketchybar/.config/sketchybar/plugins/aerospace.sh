#!/usr/bin/env bash
# AeroSpace workspace indicator for SketchyBar
# Called from sketchybarrc with workspace number as $1.
# Triggered on `aerospace_workspace_change` event.
# Reads $FOCUSED_WORKSPACE env from AeroSpace exec-on-workspace-change.

SID="$1"

if [ -z "$FOCUSED_WORKSPACE" ]; then
  FOCUSED_WORKSPACE=$(aerospace list-workspaces --focused)
fi

if [ "$SID" = "$FOCUSED_WORKSPACE" ]; then
  sketchybar --set "$NAME" \
             background.color=0xffff5fff \
             icon.color=0xff000000
else
  sketchybar --set "$NAME" \
             background.color=0x44ffffff \
             icon.color=0xffffffff
fi
