#!/usr/bin/env bash
# SPDX-FileCopyrightText: 2026 M5Stack Technology CO LTD
# SPDX-License-Identifier: MIT

set -euo pipefail

test_build="${1:?usage: check-emulator-builds.sh <test-build> <production-build>}"
production_build="${2:?missing production build}"
scratch="$(mktemp -d)"
trap 'rm -rf "$scratch"' EXIT

for variant in test production; do
  if [[ "$variant" == test ]]; then
    build="$test_build"
    expected=ON
  else
    build="$production_build"
    expected=OFF
  fi
  # CMake may record command-line values as BOOL or UNINITIALIZED.
  if ! grep -Eq "^BUILD_TESTING:[^=]+=${expected}$" "$build/CMakeCache.txt"; then
    echo "Expected BUILD_TESTING=$expected in $build" >&2
    exit 1
  fi
  strings "$build/cardputer-zero-emu" > "$scratch/$variant.txt"
done

for marker in EMU_TEST_CLICK_FRAME EMU_TEST_KEY_FRAME click_delivered=; do
  if ! grep -Fq "$marker" "$scratch/test.txt"; then
    echo "Positive control missing from test binary: $marker" >&2
    exit 1
  fi
  if grep -Fq "$marker" "$scratch/production.txt"; then
    echo "Input test instrumentation found in production binary: $marker" >&2
    exit 1
  fi
done
echo 'Test instrumentation present; production instrumentation absent.'
