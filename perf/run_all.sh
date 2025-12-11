#!/usr/bin/env bash
set -euo pipefail

BASE_URL=${BASE_URL:-http://localhost:8080}
SCRIPT=perf/k6/reactive_vs_imperative.js

OUT_DIR=perf/results
mkdir -p "$OUT_DIR/imperative" "$OUT_DIR/reactive"

RPS_LEVELS=("100" "300" "600")
RUNS=(1 2 3)

warmup_duration="3m"
measure_duration="10m"

for rps in "${RPS_LEVELS[@]}"; do
  echo "=== RPS $rps: Warm-up imperative ==="
  k6 run \
    -e BASE_URL="$BASE_URL" \
    -e VARIANT=imperative \
    -e RPS="$rps" \
    -e DURATION="$warmup_duration" \
    "$SCRIPT" > /dev/null

  echo "=== RPS $rps: Warm-up reactive ==="
  k6 run \
    -e BASE_URL="$BASE_URL" \
    -e VARIANT=reactive \
    -e RPS="$rps" \
    -e DURATION="$warmup_duration" \
    "$SCRIPT" > /dev/null

  for run in "${RUNS[@]}"; do
    echo "=== RPS $rps: run $run (imperative) ==="
    k6 run \
      -e BASE_URL="$BASE_URL" \
      -e VARIANT=imperative \
      -e RPS="$rps" \
      -e DURATION="$measure_duration" \
      --out "csv=$OUT_DIR/imperative/${rps}rps_run${run}.csv" \
      "$SCRIPT"

    echo "=== RPS $rps: run $run (reaktive) ==="
    k6 run \
      -e BASE_URL="$BASE_URL" \
      -e VARIANT=reactive \
      -e RPS="$rps" \
      -e DURATION="$measure_duration" \
      --out "csv=$OUT_DIR/reactive/${rps}rps_run${run}.csv" \
      "$SCRIPT"
  done
done

echo "All runs completed."
