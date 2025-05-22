#!/usr/bin/env bash
set -eu

# The sink we want to exclude (full persistent name)
TRAP_SINK="alsa_output.pci-0000_02_00.3.Headphones"

# Get current default sink (full name)
defaultSink=$(pactl info | grep "Default Sink:" | cut -d' ' -f3)
echo "Current default: $defaultSink"

# List all sinks, excluding the TRAP_SINK by NAME
sinks=()
while read -r id name _; do
    if [[ "$name" != "$TRAP_SINK" ]]; then
        sinks+=("$name")
    fi
done <<< "$(pactl list sinks short)"

echo "Available sinks (excluding trap):"
printf '%s\n' "${sinks[@]}"

# Find current position in the filtered list
for i in "${!sinks[@]}"; do
    if [[ "${sinks[i]}" == "$defaultSink" ]]; then
        defaultPos=$i
        break
    fi
done

# Cycle to next sink (wrap around if needed)
newDefaultPos=$(( (defaultPos + 1) % ${#sinks[@]} ))
newDefaultSink="${sinks[$newDefaultPos]}"

# Set new default sink
pactl set-default-sink "$newDefaultSink"

# Notification with user-friendly name
sinkName=$(pactl list sinks | grep -A10 "$newDefaultSink" | grep "Description" | cut -d: -f2- | xargs)
notify-send -u low -h string:x-canonical-private-synchronous:sink "Current Audio Output Device:" "$sinkName"

# Move all active streams to the new sink
pactl list short sink-inputs | awk '{print $1}' | xargs -r -I{} pactl move-sink-input {} "$newDefaultSink"
