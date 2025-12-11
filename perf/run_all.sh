#!/usr/bin/env bash
set -euo pipefail

BASE_URL=${BASE_URL:-http://localhost:8080}
SCRIPT=perf/k6/reactive_vs_imperative.js

OUT_DIR=perf/results
mkdir -p "$OUT_DIR/imperative" "$OUT_DIR/reactive"

# Index-Datei für Excel (Meta-Infos zu allen Runs)
INDEX_FILE="$OUT_DIR/index.csv"
echo "variant,rps,run,file" > "$INDEX_FILE"

RPS_LEVELS=("100" "300" "600")
RUNS=(1 2 3)

warmup_duration="3m"
measure_duration="10m"

run_scenario () {
  local variant=$1
  local rps=$2
  local run=$3

  local out_file="$OUT_DIR/${variant}/${variant}_${rps}rps_run${run}.csv"

  echo "=== ${variant}, ${rps} RPS, Lauf ${run} ==="

  k6 run \
    -e BASE_URL="$BASE_URL" \
    -e VARIANT="$variant" \
    -e RPS="$rps" \
    -e DURATION="$measure_duration" \
    --out "csv=${out_file}" \
    "$SCRIPT"

  # Zeile in Index-Datei ergänzen
  echo "${variant},${rps},${run},${out_file}" >> "$INDEX_FILE"
}

for rps in "${RPS_LEVELS[@]}"; do
  echo "=== Warm-up, ${rps} RPS, imperativ ==="
  k6 run \
    -e BASE_URL="$BASE_URL" \
    -e VARIANT=imperative \
    -e RPS="$rps" \
    -e DURATION="$warmup_duration" \
    "$SCRIPT" > /dev/null

  echo "=== Warm-up, ${rps} RPS, reaktiv ==="
  k6 run \
    -e BASE_URL="$BASE_URL" \
    -e VARIANT=reactive \
    -e RPS="$rps" \
    -e DURATION="$warmup_duration" \
    "$SCRIPT" > /dev/null

  for run in "${RUNS[@]}"; do
    # ABAB-Muster: imperativ, dann reaktiv
    run_scenario "imperative" "$rps" "$run"
    run_scenario "reactive" "$rps" "$run"
  done
done

echo "Alle Läufe abgeschlossen. Ergebnisse in ${OUT_DIR}."
