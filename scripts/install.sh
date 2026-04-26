#!/usr/bin/env bash
# Build, install and activate the ES8389 codec driver on a Raspberry Pi.
#
# Run on the target Pi (Debian/RPi OS, kernel headers package installed).

set -euo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
SRC="$HERE/../src"

cd "$SRC"

echo "[1/4] Building snd-soc-es8389.ko ..."
make

echo "[2/4] Installing module ..."
KVER="$(uname -r)"
sudo install -m 644 snd-soc-es8389.ko \
    "/lib/modules/${KVER}/kernel/sound/soc/codecs/"
sudo depmod -a

echo "[3/4] Compiling and installing device-tree overlay ..."
dtc -I dts -O dtb -@ -o dts/es8389-soundcard.dtbo dts/es8389-soundcard.dts
sudo install -m 644 dts/es8389-soundcard.dtbo /boot/firmware/overlays/

echo "[4/4] Patching /boot/firmware/config.txt ..."
if ! grep -q '^dtoverlay=es8389-soundcard' /boot/firmware/config.txt; then
    echo 'dtoverlay=es8389-soundcard' | sudo tee -a /boot/firmware/config.txt
fi

echo
echo "Done. Reboot the Pi for the new overlay to take effect:"
echo "    sudo reboot"
