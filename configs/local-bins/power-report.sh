#!/usr/bin/env bash
# Instant power diagnosis: real draw, projected runtime, gauge health.
set -euo pipefail

B=/sys/class/power_supply/BAT0
r() { cat "$B/$1" 2>/dev/null || echo 0; }

status=$(r status)
cap=$(r capacity)
now=$(r energy_now)
full=$(r energy_full)
design=$(r energy_full_design)
power=$(r power_now)
cycles=$(r cycle_count)

wh()  { awk -v v="$1" 'BEGIN{printf "%.2f", v/1000000}'; }
watt() { awk -v v="$1" 'BEGIN{printf "%.2f", v/1000000}'; }

echo "Estado:        $status  (${cap}%)"
echo "Energía:       $(wh "$now") Wh de $(wh "$full") Wh"
echo "Salud:         $(awk -v f="$full" -v d="$design" 'BEGIN{printf "%.1f%%", f*100/d}') del diseño ($(wh "$design") Wh) — $cycles ciclos"
echo "Consumo:       $(watt "$power") W"

if [ "$power" -gt 0 ]; then
  if [ "$status" = "Discharging" ]; then
    echo "Autonomía:     $(awk -v e="$now" -v p="$power" 'BEGIN{h=e/p; printf "%dh %02dm", int(h), (h-int(h))*60}')"
    echo "Desde 100%:    $(awk -v e="$full" -v p="$power" 'BEGIN{h=e/p; printf "%dh %02dm", int(h), (h-int(h))*60}')"
  else
    echo "Carga completa en $(awk -v e="$full" -v n="$now" -v p="$power" 'BEGIN{h=(e-n)/p; printf "%dh %02dm", int(h), (h-int(h))*60}')"
  fi
fi

echo
echo "── Mayores consumidores de CPU ──"
ps -eo pcpu,comm --sort=-pcpu --no-headers | head -8 | awk '{printf "  %5s%%  %s\n", $1, $2}'

echo
echo "── Ajustes de energía ──"
echo "  Gobernador:  $(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor 2>/dev/null)"
echo "  EPP:         $(cat /sys/devices/system/cpu/cpu0/cpufreq/energy_performance_preference 2>/dev/null)"
echo "  Boost:       $(cat /sys/devices/system/cpu/cpufreq/boost 2>/dev/null || echo n/a)"
echo "  Perfil:      $(cat /sys/firmware/acpi/platform_profile 2>/dev/null)"
echo "  Brillo:      $(brightnessctl -m 2>/dev/null | cut -d, -f4 || echo n/a)"
