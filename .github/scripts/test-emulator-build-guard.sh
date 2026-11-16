#!/usr/bin/env bash
# SPDX-FileCopyrightText: 2026 M5Stack Technology CO LTD
# SPDX-License-Identifier: MIT

set -euo pipefail

guard="$(cd "$(dirname "$0")" && pwd)/check-emulator-builds.sh"
scratch="$(mktemp -d)"
trap 'rm -rf "$scratch"' EXIT
mkdir "$scratch/test" "$scratch/production"
reset_fixture() {
  printf 'BUILD_TESTING:%s=ON\n' "$1" > "$scratch/test/CMakeCache.txt"
  printf 'BUILD_TESTING:%s=OFF\n' "$1" > "$scratch/production/CMakeCache.txt"
  printf '%s\n' EMU_TEST_CLICK_FRAME EMU_TEST_KEY_FRAME click_delivered= > "$scratch/test/cardputer-zero-emu"
  printf 'production executable\n' > "$scratch/production/cardputer-zero-emu"
}
expect_failure() {
  if bash "$guard" "$scratch/test" "$scratch/production" > "$scratch/output" 2>&1; then
    echo "Guard incorrectly accepted: $1" >&2
    exit 1
  fi
  grep -Fq "$2" "$scratch/output"
}
for cache_type in BOOL UNINITIALIZED; do
  reset_fixture "$cache_type"
  bash "$guard" "$scratch/test" "$scratch/production"
done
reset_fixture BOOL
printf '%s\n' EMU_TEST_CLICK_FRAME click_delivered= > "$scratch/test/cardputer-zero-emu"
expect_failure 'renamed/missing test marker' 'Positive control missing'
reset_fixture BOOL
printf 'EMU_TEST_KEY_FRAME\n' >> "$scratch/production/cardputer-zero-emu"
expect_failure 'instrumented production binary' 'instrumentation found'
reset_fixture BOOL
printf 'BUILD_TESTING:UNINITIALIZED=ON\n' > "$scratch/production/CMakeCache.txt"
expect_failure 'wrong production cache setting' 'Expected BUILD_TESTING=OFF'
echo 'Guard regression checks passed (2 positive, 3 negative controls).'
