#!/usr/bin/env bash
set -u

number_or_zero() {
  [[ \${1:-} =~ ^[0-9]+([.][0-9]+)?$ ]] && printf '%s' "$1" || printf '0'
}

read_cpu_usage() {
  local _ user nice system idle iowait irq softirq steal _guest
  read -r _ user nice system idle iowait irq softirq steal _guest < /proc/stat
  local idle_before=$((idle + iowait))
  local total_before=$((user + nice + system + idle + iowait + irq + softirq + steal))
  sleep 0.15
  read -r _ user nice system idle iowait irq softirq steal _guest < /proc/stat
  local idle_after=$((idle + iowait))
  local total_after=$((user + nice + system + idle + iowait + irq + softirq + steal))
  local delta=$((total_after - total_before))
  ((delta > 0)) && printf '%d' "$((100 * (delta - idle_after + idle_before) / delta))" || printf '0'
}

read_cpu_temp() {
  local hwmon name input value
  for hwmon in /sys/class/hwmon/hwmon*; do
    [[ -r $hwmon/name ]] || continue
    read -r name < "$hwmon/name"
    case $name in
      coretemp|k10temp|zenpower)
        for input in "$hwmon"/temp*_input; do
          [[ -r $input ]] || continue
          read -r value < "$input"
          ((value >= 1000 && value <= 150000)) && {
            awk -v value="$value" 'BEGIN {printf "%.0f", value / 1000}'
            return
          }
        done
        ;;
    esac
  done
  local zone type
  for zone in /sys/class/thermal/thermal_zone*; do
    [[ -r $zone/type && -r $zone/temp ]] || continue
    read -r type < "$zone/type"
    case $type in
      x86_pkg_temp|cpu_thermal|soc_thermal)
        read -r value < "$zone/temp"
        ((value >= 1000 && value <= 150000)) && {
          awk -v value="$value" 'BEGIN {printf "%.0f", value / 1000}'
          return
        }
        ;;
    esac
  done
  printf '0'
}

read_gpu() {
  local card device busy=0 frequency=0 temperature=0 hwmon input value
  for card in /sys/class/drm/card[0-9]*; do
    [[ -r $card/device/vendor ]] || continue
    [[ $(<"$card/device/vendor") == "0x8086" ]] || continue
    device=$card/device
    [[ -r $device/gpu_busy_percent ]] && read -r busy < "$device/gpu_busy_percent"
    [[ -r $card/gt_cur_freq_mhz ]] && read -r frequency < "$card/gt_cur_freq_mhz"
    [[ -r $device/gt_cur_freq_mhz ]] && read -r frequency < "$device/gt_cur_freq_mhz"
    for hwmon in "$device"/hwmon/hwmon*; do
      for input in "$hwmon"/temp*_input; do
        [[ -r $input ]] || continue
        read -r value < "$input"
        ((value >= 1000 && value <= 150000)) && {
          temperature=$(awk -v value="$value" 'BEGIN {printf "%.0f", value / 1000}')
          break 2
        }
      done
    done
    break
  done
  printf '%s|%s|%s' "$(number_or_zero "$busy")" "$(number_or_zero "$temperature")" "$(number_or_zero "$frequency")"
}

cpu_usage=$(read_cpu_usage)
cpu_temp=$(read_cpu_temp)
cpu_frequency=$(awk '{sum += $1; count++} END {if (count) printf "%.1f", sum / count / 1000000; else print 0}' \
  /sys/devices/system/cpu/cpu*/cpufreq/scaling_cur_freq 2>/dev/null)
read -r memory_total memory_used < <(free -b | awk '/Mem:/ {print $2, $3}')
memory_percent=$((100 * memory_used / memory_total))
memory_text=$(awk -v used="$memory_used" -v total="$memory_total" \
  'BEGIN {printf "%.1f / %.1f GiB", used / 1073741824, total / 1073741824}')
read -r disk_total disk_used disk_percent < <(df -B1 / | awk 'NR == 2 {gsub(/%/, "", $5); print $2, $3, $5}')
disk_text=$(awk -v used="$disk_used" -v total="$disk_total" \
  'BEGIN {printf "%.1f / %.1f GiB", used / 1073741824, total / 1073741824}')

printf '%s|%s|%s|%s|%s|%s|%s|' \
  "$cpu_usage" "$cpu_temp" "$cpu_frequency" "$memory_percent" "$memory_text" "$disk_percent" "$disk_text"
read_gpu
printf '\n'
