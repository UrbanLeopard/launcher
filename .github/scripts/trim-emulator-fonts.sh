#!/usr/bin/env bash
# SPDX-FileCopyrightText: 2026 M5Stack Technology CO LTD
# SPDX-License-Identifier: MIT

set -euo pipefail

package="${1:?usage: trim-emulator-fonts.sh <staged-package>}"
fonts="$package/APPLaunch/share/font"
# Remove only packaged copies. Keep NotoSansCJK: APPLaunch settings use cjk_sans().
rm "$fonts/NotoSerifCJK-Regular.ttc" "$fonts/AlibabaPuHuiTi-3-35-Thin.ttf"
