#!/usr/bin/env bash
# SPDX-FileCopyrightText: 2026 M5Stack Technology CO LTD
# SPDX-License-Identifier: MIT

set -euo pipefail

archive="${1:?usage: smoke-emulator-package.sh <archive.tar.gz>}"
scratch="$(mktemp -d)"
trap 'rm -rf "$scratch"' EXIT
tar xzf "$archive" -C "$scratch"
cd "$scratch/CardputerZero-Emulator"
binary=./cardputer-zero-emu
if [[ -f "$binary.exe" ]]; then binary="$binary.exe"; fi
test -f "$binary"
for resource in apps assets images APPLaunch/share/images APPLaunch/share/audio; do
  test -d "$resource"
done
for font in AlibabaPuHuiTi-3-55-Regular.ttf NotoSansCJK-Regular.ttc JetBrainsMono-Regular.ttf; do
  test -s "APPLaunch/share/font/$font"
done
mkdir config
export APPLAUNCH_SDL_CONFIG_DIR="$PWD/config"
export SDL_VIDEODRIVER=dummy SDL_AUDIODRIVER=dummy EMU_TEST_QUIT_FRAME=20
if ! "$binary" > "$scratch/startup.log" 2>&1; then
  cat "$scratch/startup.log"
  exit 1
fi
cat "$scratch/startup.log"
if ! grep -Eq '\[HOME\] preloaded ([1-9][0-9]*)/\1 unique icons' "$scratch/startup.log"; then
  echo 'Packaged home icons did not all load.' >&2
  exit 1
fi
echo 'Unpacked production archive started and exited successfully.'
