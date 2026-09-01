#!/usr/bin/env bash
# Appends one battery sample per interval so abrupt percentage drops can be
# reconstructed after the fact. Run via the battery-log user service.
set -euo pipefail

B=/sys/class/power_supply/BAT0
OUT="${XDG_STATE_HOME:-$HOME/.local/state}/battery.csv"
INTERVAL="${BATTERY_LOG_INTERVAL:-30}"

mkdir -p "$(dirname "$OUT")"
[ -s "$OUT" ] || echo "ts,capacity,energy_now_uWh,power_now_uW,voltage_now_uV,status,load1" > "$OUT"

while true; do
  printf "%s,%s,%s,%s,%s,%s,%s\n" \
    "$(date +%s)" \
    "$(cat $B/capacity)" \
    "$(cat $B/energy_now)" \
    "$(cat $B/power_now)" \
    "$(cat $B/voltage_now)" \
    "$(cat $B/status)" \
    "$(cut -d' ' -f1 /proc/loadavg)" >> "$OUT"
  sleep "$INTERVAL"
done
