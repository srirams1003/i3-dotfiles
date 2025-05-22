#!/bin/bash

arg="${1:-}"

set_sink_and_move_inputs() {
  local SINK="$1"
  local PROFILE="$2"
  local CARD="$3"

  # Set card profile if provided (e.g., for Bluetooth devices)
  if [[ -n "$PROFILE" && -n "$CARD" ]]; then
    pactl set-card-profile "$CARD" "$PROFILE"
  fi

  # Set default sink
  pactl set-default-sink "$SINK"

  # Move all current audio streams to the new sink
  pactl list short sink-inputs | awk '{print $1}' | while read input; do
    pactl move-sink-input "$input" "$SINK"
  done
}

case "$arg" in
  --speakers)
    SINK="alsa_output.pci-0000_02_00.3.Speakers"
    set_sink_and_move_inputs "$SINK" "" ""
    notify-send "🔊 Switched to speakers!"
    ;;
  --external)
    SINK="alsa_output.pci-0000_00_1f.3.hdmi-stereo"
    set_sink_and_move_inputs "$SINK" "" ""
    notify-send "Switched to HDMI speakers!"
    ;;
  --headphones)
    SINK="bluez_output.E8_9E_13_09_D4_4D.1"  # Bluetooth sink name
    PROFILE="a2dp-sink"                      # Make sure we use high-quality output
    CARD="bluez_card.E8_9E_13_09_D4_4D"      # Bluetooth card name

    set_sink_and_move_inputs "$SINK" "$PROFILE" "$CARD"
    notify-send "🎧 Switched to Bluetooth headphones!"
    ;;
  --middle)
    notify-send "🖱️ Middle click!"
    ;;
  *)
    echo "שׂ"
    ;;
esac



