# ES8389 编解码器驱动（Raspberry Pi / PiSugar HAT）

[English](README.md) | [简体中文](README.zh-CN.md)

这是一个面向 Raspberry Pi 系列（PiSugar HAT）的 **ES8389** 音频编解码器项目，包含内核外（out-of-tree）ASoC 驱动。

本仓库包含：

- ES8389 驱动源码（`snd-soc-es8389`）
- `simple-audio-card` 设备树 overlay

## 硬件信息

| 项目 | 说明 |
| --- | --- |
| 目标平台 | Raspberry Pi 系列（BCM283x I2S + I2C） |
| 已验证板卡 | Raspberry Pi 3B+ (`PI3BP.local`) |
| Codec | ES8389（I2C 地址 `0x10`，位于 `/dev/i2c-1`） |
| MCLK | 外部固定时钟，24.576 MHz |
| I2S 角色 | Codec 为从机；BCM2835 I2S 提供 BCLK/LRCK |
| 引脚 | I2C SDA=P3，SCL=P5；I2S BCLK=P12，LRCK=P35，DOUT=P38，DIN=P40 |

## 验证状态

- 驱动目标是树莓派通用方案。
- 本仓库当前仅在 Raspberry Pi 3B+ 上完成了端到端验证。
- 其他树莓派型号可能需要按板级差异调整引脚或 overlay 配置。

## 验证结果（Pi 3B+）

```text
file             dur    peak     rms       dc  clip%   pre_dB  sine_dB  post_dB   sig_dB     THDN  pops
round1.wav      60.0   0.045  0.0040 -0.00001  0.000    -74.3    -37.2    -73.6    -44.7      3.4     0
round2.wav      60.0   0.043  0.0038 -0.00001  0.000    -74.5    -37.7    -73.8    -45.5      4.2     0
round3.wav      60.0   0.042  0.0038 -0.00001  0.000    -73.1    -37.7    -72.2    -45.4      4.2     0
round4.wav      60.0   0.042  0.0037 -0.00001  0.000    -73.4    -37.9    -73.7    -45.8      4.4     0
round5.wav      60.0   0.044  0.0037 -0.00001  0.000    -74.5    -37.9    -74.0    -45.7      4.3     0

ALL ROUNDS PASSED
```

结论：背景噪声约 -74 dBFS，正弦波约 -37 dBFS（比环境噪声高约 37 dB），无削顶、无明显 DC 偏移、无中途爆音。

## 项目功能

- 按当前 Raspberry Pi 内核编译 `snd-soc-es8389.ko`
- 安装 `es8389-soundcard.dtbo` 到 `/boot/firmware/overlays/`
- 确保 `/boot/firmware/config.txt` 中存在 `dtoverlay=es8389-soundcard`

## 目录结构

```text
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

## 编译与安装（在 Pi 上执行）

请在仓库根目录执行：

```sh
sudo apt-get install -y build-essential device-tree-compiler \
    linux-headers-$(uname -r)

cd scripts
./install.sh
sudo reboot
```

重启后，确认声卡已加载：

```sh
aplay -l   | grep es8389
arecord -l | grep es8389
```

## 兼容性说明

上游 `es8389.c`（kernel >= 6.13）使用 `snd_soc_dapm_kcontrol_to_*` 辅助函数；
Raspberry Pi 6.12 内核使用较旧的 `snd_soc_dapm_kcontrol_*` 命名。
本仓库中的源码已适配 6.12.x，可在当前 RPi OS 上直接构建，无需额外补丁步骤。
