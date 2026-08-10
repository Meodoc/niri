#!/usr/bin/env bash
# lock-and-off.sh — smooth, all-monitor dim -> lock -> power off, reproducing
# Noctalia's idle fade for a manual keybind (no global idle timeout involved).

FADE=1.0                                  # fade length in seconds; match fadeSeconds in dim.qml
QML="$HOME/.config/niri/scripts/dim.qml"  # adjust if you put dim.qml elsewhere

# 1. Start the black fade overlay on every monitor (separate quickshell instance).
qs -p "$QML" &
OVERLAY=$!

# 2. Wait for the fade to reach black. The +0.4 covers quickshell's startup latency
#    (the overlay doesn't begin animating until the instance has loaded).
sleep "$(awk "BEGIN{print $FADE + 0.4}")"

# 3. Now that the screen is black: lock the session, then cut monitor power.
#    Fade-then-lock is required — a lock surface renders above layer-shell overlays,
#    so locking earlier would hide the fade.
qs -c noctalia-shell ipc call lockScreen lock
qs -c noctalia-shell ipc call monitors off

# 4. Tear the overlay down while the panels are off (invisible). On wake, niri powers
#    the monitors back on with any input and Noctalia's lock screen is what shows.
sleep 0.15
kill "$OVERLAY" 2>/dev/null
