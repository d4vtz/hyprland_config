pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

QtObject {
    id: root
    property string network: "--"
    property bool wifiEnabled: false
    property bool bluetoothEnabled: false
    property string battery: "--"
    property string batteryState: "Sin batería"
    property string batteryTime: "--"
    property real brightness: 0
    property real cpuUsage: 0
    property real cpuTemperature: 0
    property real cpuFrequency: 0
    property real memoryUsage: 0
    property string memoryText: "--"
    property real diskUsage: 0
    property string diskText: "--"
    property string powerProfile: "balanced"
    property bool nightLightEnabled: false
    property string userName: ""
    property string hostName: ""
    property string uptime: ""

    function refresh() {
        networkProcess.running = true
        batteryProcess.running = true
        brightnessProcess.running = true
        sensorsProcess.running = true
        stateProcess.running = true
        identityProcess.running = true
    }

    property Timer timer: Timer {
        interval: 5000
        repeat: true
        running: true
        triggeredOnStart: true
        onTriggered: root.refresh()
    }

    property Process networkProcess: Process {
        command: ["sh", "-c", "printf '%s|' \"$(nmcli -t -f WIFI general 2>/dev/null)\"; nmcli -t -f TYPE,STATE,CONNECTION device 2>/dev/null | awk -F: '$1 == \"wifi\" && $2 == \"connected\" {print $3; exit}'"]
        stdout: StdioCollector {
            onStreamFinished: {
                const fields = text.trim().split("|")
                root.wifiEnabled = fields[0] === "enabled"
                root.network = fields[1] || (root.wifiEnabled ? "Sin conexión" : "Wi-Fi apagado")
            }
        }
    }

    property Process batteryProcess: Process {
        command: ["sh", "-c", "b=$(find /sys/class/power_supply -maxdepth 1 -name 'BAT*' -print -quit); [ -z \"$b\" ] && { printf 'CA|Sin batería|--'; exit; }; cap=$(cat \"$b/capacity\"); st=$(cat \"$b/status\"); case \"$st\" in Charging) label=Cargando;; Discharging) label=Descargando;; Full) label='Carga completa';; *) label=\"$st\";; esac; now=$(cat \"$b/energy_now\" 2>/dev/null || cat \"$b/charge_now\" 2>/dev/null || echo 0); rate=$(cat \"$b/power_now\" 2>/dev/null || cat \"$b/current_now\" 2>/dev/null || echo 0); if [ \"\${rate:-0}\" -gt 0 ] 2>/dev/null; then secs=$((now*3600/rate)); printf '%s|%s|%dh %02d min' \"$cap\" \"$label\" $((secs/3600)) $(((secs%3600)/60)); else printf '%s|%s|--' \"$cap\" \"$label\"; fi"]
        stdout: StdioCollector {
            onStreamFinished: {
                const fields = text.trim().split("|")
                root.battery = fields[0] || "CA"
                root.batteryState = fields[1] || "Sin batería"
                root.batteryTime = fields[2] || "--"
            }
        }
    }

    property Process sensorsProcess: Process {
        command: ["sh", "-c", "read _ u n s i w x y z _ < /proc/stat; idle1=$((i+w)); total1=$((u+n+s+i+w+x+y+z)); sleep .15; read _ u n s i w x y z _ < /proc/stat; idle2=$((i+w)); total2=$((u+n+s+i+w+x+y+z)); cpu=$((100*(total2-total1-idle2+idle1)/(total2-total1))); temp=$(awk '{printf \"%.0f\", $1/1000}' /sys/class/thermal/thermal_zone*/temp 2>/dev/null | head -n1); freq=$(awk '{sum+=$1;n++} END {if(n) printf \"%.1f\",sum/n/1000000;else print 0}' /sys/devices/system/cpu/cpu*/cpufreq/scaling_cur_freq 2>/dev/null); read mt mu < <(free -b | awk '/Mem:/ {print $2,$3}'); memp=$((100*mu/mt)); mem=$(awk -v u=$mu -v t=$mt 'BEGIN{printf \"%.1f / %.1f GiB\",u/1073741824,t/1073741824}'); read size used pct < <(df -B1 / | awk 'NR==2{gsub(/%/,\"\",$5);print $2,$3,$5}'); disk=$(awk -v u=$used -v t=$size 'BEGIN{printf \"%.1f / %.1f GiB\",u/1073741824,t/1073741824}'); printf '%s|%s|%s|%s|%s|%s|%s' \"$cpu\" \"\${temp:-0}\" \"$freq\" \"$memp\" \"$mem\" \"$pct\" \"$disk\""]
        stdout: StdioCollector {
            onStreamFinished: {
                const fields = text.trim().split("|")
                root.cpuUsage = Number(fields[0]) || 0
                root.cpuTemperature = Number(fields[1]) || 0
                root.cpuFrequency = Number(fields[2]) || 0
                root.memoryUsage = (Number(fields[3]) || 0) / 100
                root.memoryText = fields[4] || "--"
                root.diskUsage = (Number(fields[5]) || 0) / 100
                root.diskText = fields[6] || "--"
            }
        }
    }

    property Process stateProcess: Process {
        command: ["sh", "-c", "bt=$(bluetoothctl show 2>/dev/null | awk '/Powered:/{print $2;exit}'); profile=$(powerprofilesctl get 2>/dev/null || echo balanced); pgrep -x hyprsunset >/dev/null && night=1 || night=0; printf '%s|%s|%s' \"$bt\" \"$profile\" \"$night\""]
        stdout: StdioCollector {
            onStreamFinished: {
                const fields = text.trim().split("|")
                root.bluetoothEnabled = fields[0] === "yes"
                root.powerProfile = fields[1] || "balanced"
                root.nightLightEnabled = fields[2] === "1"
            }
        }
    }

    property Process brightnessProcess: Process {
        command: ["sh", "-c", "brightnessctl -m | awk -F, '{gsub(/%/, \"\", $4); print $4; exit}'"]
        stdout: StdioCollector {
            onStreamFinished: root.brightness = Math.max(0, Math.min(1, Number(text.trim()) / 100))
        }
    }

    property Process identityProcess: Process {
        command: ["sh", "-c", "printf '%s|%s|%s' \"$(id -un)\" \"$(hostnamectl --static 2>/dev/null || hostname)\" \"$(uptime -p | sed 's/^up //')\""]
        stdout: StdioCollector {
            onStreamFinished: {
                const fields = text.trim().split("|")
                root.userName = fields[0] || "usuario"
                root.hostName = fields[1] || "equipo"
                root.uptime = fields[2] || ""
            }
        }
    }
}
