#!/usr/bin/env bash
# Record 5 seconds and play back through the ES8389 sound card.
#
# Run on the target Pi after driver installation.

set -euo pipefail

CARD_NAME="es8389soundcard"
TEST_FILE="/tmp/es8389-test.wav"
DURATION=5
RATE=48000

echo "[1/3] Finding ES8389 sound card ..."
PLAY_DEV=$(arecord -l 2>/dev/null | grep -i "$CARD_NAME" | head -1 | sed -n 's/card \([0-9]*\).*device \([0-9]*\).*/\1,\2/p')
CAP_DEV=$(arecord -l 2>/dev/null | grep -i "$CARD_NAME" | head -1 | sed -n 's/card \([0-9]*\).*device \([0-9]*\).*/\1,\2/p')

if [ -z "$PLAY_DEV" ] || [ -z "$CAP_DEV" ]; then
    echo "ERROR: ES8389 sound card not found. Is the driver loaded?"
    echo
    echo "Available capture devices:"
    arecord -l
    echo
    exit 1
fi

echo "  Device: hw:$PLAY_DEV (playback) / hw:$CAP_DEV (capture)"

echo "[2/3] Recording ${DURATION}s to $TEST_FILE ..."
arecord -D "hw:$CAP_DEV" -f S16_LE -r "$RATE" -c 2 -d "$DURATION" "$TEST_FILE"

echo "[3/3] Playing back $TEST_FILE ..."
aplay -D "hw:$PLAY_DEV" "$TEST_FILE"

echo
echo "Done. Test file saved at $TEST_FILE"
