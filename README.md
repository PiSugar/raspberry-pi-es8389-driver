# ES8389 Codec Driver for Raspberry Pi (PiSugar HAT)

[English](README.md) | [简体中文](README.zh-CN.md)

Out-of-tree Linux ASoC driver package for the
**ES8389** codec on Raspberry Pi boards (PiSugar HAT).

This repository contains:

- ES8389 codec driver source (`snd-soc-es8389`)
- Device-tree overlay for `simple-audio-card`

## Hardware

| Item | Value |
| --- | --- |
| Target platform | Raspberry Pi family (BCM283x I2S + I2C) |
| Verified board | Raspberry Pi 3B+ (`PI3BP.local`) |
| Codec | ES8389 (I²C addr `0x10`, on `/dev/i2c-1`) |
| MCLK | External fixed-frequency oscillator, 24.576 MHz |
| I²S role | Codec is **slave**; BCM2835 I²S provides BCLK/LRCK |
| Pins | I²C SDA=P3, SCL=P5; I²S BCLK=P12, LRCK=P35, DOUT=P38, DIN=P40 |

## Validation status

- Driver is intended to be generic for Raspberry Pi boards.
- End-to-end validation in this repository is currently completed on Raspberry Pi 3B+ only.
- Other Raspberry Pi models may require board-specific pin and overlay adjustments.

## Validation results (Pi 3B+)

```
file             dur    peak     rms       dc  clip%   pre_dB  sine_dB  post_dB   sig_dB     THDN  pops
round1.wav      60.0   0.045  0.0040 -0.00001  0.000    -74.3    -37.2    -73.6    -44.7      3.4     0
round2.wav      60.0   0.043  0.0038 -0.00001  0.000    -74.5    -37.7    -73.8    -45.5      4.2     0
round3.wav      60.0   0.042  0.0038 -0.00001  0.000    -73.1    -37.7    -72.2    -45.4      4.2     0
round4.wav      60.0   0.042  0.0037 -0.00001  0.000    -73.4    -37.9    -73.7    -45.8      4.4     0
round5.wav      60.0   0.044  0.0037 -0.00001  0.000    -74.5    -37.9    -74.0    -45.7      4.3     0

ALL ROUNDS PASSED
```

Summary: background noise around -74 dBFS, sine around -37 dBFS (about 37 dB above ambient), no clipping, no DC drift, and no mid-stream pops.

## What this project does

- Builds `snd-soc-es8389.ko` against the current Raspberry Pi kernel
- Installs `es8389-soundcard.dtbo` to `/boot/firmware/overlays/`
- Ensures `dtoverlay=es8389-soundcard` exists in `/boot/firmware/config.txt`

## Layout

```
src/
    es8389.c          # Upstream Linux driver (sound/soc/codecs/es8389.c)
    es8389.h          # Upstream Linux header (sound/soc/codecs/es8389.h)
    Makefile          # Out-of-tree kernel module build
    dts/
        es8389-soundcard.dts    # simple-audio-card overlay (codec-slave)
        es8389-soundcard.dtbo   # Compiled overlay
scripts/
    install.sh        # Build + install on the Pi
```

## Build & install (on the Pi)

From the repository root:

```sh
sudo apt-get install -y build-essential device-tree-compiler \
    linux-headers-$(uname -r)

cd scripts
./install.sh
sudo reboot
```

After reboot, verify the codec card is present:

```sh
aplay -l   | grep es8389
arecord -l | grep es8389
```

## Compatibility notes

Upstream `es8389.c` (kernel >= 6.13) uses
`snd_soc_dapm_kcontrol_to_*` helpers. Raspberry Pi kernel 6.12 uses the
older `snd_soc_dapm_kcontrol_*` naming. The source in this repository has
already been adapted for 6.12.x, so it builds directly on current RPi OS
without extra patch steps.
