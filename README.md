# Orion Shell

Shell de escritorio para Hyprland sobre Arch Linux. Quickshell/QML proporciona la capa visual y Hyprland/Lua conserva la gestión del compositor. El objetivo es una experiencia integrada y configurable con identidad Dracula, superficies tipo Material y módulos reutilizables.

## Diseño

- Configuración de Hyprland completamente en Lua.
- Tema Dracula desacoplado y preparado para añadir otras paletas.
- Layout master con siete espacios persistentes.
- Orion Shell sobre Quickshell, modular y animada, con reloj centrado.
- Sistema visual compartido (`Theme`, `Surface`, `Card`, `SectionTitle`, `ToggleTile`).
- Dashboard nativo con métricas, conectividad, energía y almacenamiento.
- Lanzador nativo de Orion Shell, centro de actividad, centro de control, monitor del sistema y ajustes propios.
- Hyprpaper, Hyprlock e Hypridle.
- Capturas con Grimblast y edición en Satty.
- Super + F1 abre una hoja de atajos filtrable.

## Dependencias

Instala los paquetes oficiales:

```bash
sudo pacman -S --needed \
  uwsm xdg-desktop-portal-hyprland polkit-kde-agent \
  kwallet kwallet-pam kwalletmanager \
  quickshell qt6-declarative qt6-svg qt6-imageformats \
  hyprpaper hyprlock hypridle \
  satty grim slurp wl-clipboard cliphist jq cava curl pacman-contrib \
  brightnessctl playerctl pavucontrol \
  bluez-utils blueman power-profiles-daemon hyprsunset intel-gpu-tools \
  pipewire wireplumber qt5-wayland qt6-wayland \
  kitty dolphin inter-font ttf-jetbrains-mono-nerd ttf-material-symbols-variable
```

Grimblast está en AUR:

```bash
paru -S grimblast-git
```

## Instalación

Clona fuera de ~/.config:

```bash
git clone https://github.com/d4vtz/hyprland_config.git ~/.local/src/hyprland_config
cd ~/.local/src/hyprland_config
```

Conserva configuraciones previas que no sean enlaces:

```bash
mv ~/.config/hypr ~/.config/hypr.backup 2>/dev/null || true
mv ~/.config/quickshell ~/.config/quickshell.backup 2>/dev/null || true
```

Instala los enlaces:

```bash
./scripts/install-links.sh
```

Valida Lua antes de iniciar la sesión:

```bash
find . -name '*.lua' -print0 | xargs -0 -n1 luac -p
```

Selecciona **Hyprland (uwsm-managed)** en Plasma Login Manager.

## Atajos principales

| Atajo | Acción |
|---|---|
| Super + F1 | Mostrar y filtrar todos los atajos |
| Super + Espacio | Abrir Orion Launcher |
| Super + D | Abrir/cerrar Orion Dashboard |
| Super + Enter | Abrir Kitty |
| Super + E | Abrir Dolphin |
| Super + B | Abrir navegador |
| Super + N | Abrir centro de actividad en Notificaciones |
| Super + Shift + V | Abrir centro de actividad en Portapapeles |
| Super + C | Abrir Centro de control |
| Super + M | Abrir Monitor del sistema |
| Super + , | Abrir ajustes de Orion Shell |
| Super + Escape | Abrir acciones de sesión |
| Super + H/J/K/L | Cambiar el foco |
| Super + flechas | Cambiar el foco |
| Super + Shift + dirección | Intercambiar ventanas |
| Super + Ctrl + flechas | Redimensionar |
| Super + 1…7 | Cambiar espacio de trabajo |
| Super + Shift + 1…7 | Mover ventana |
| Super + PageUp/PageDown | Recorrer los siete escritorios |
| Super + Ctrl + PageUp/PageDown | Recorrer solamente escritorios ocupados |
| Super + rueda | Recorrer los siete escritorios |
| Super + Ctrl + rueda | Recorrer solamente escritorios ocupados |
| Print | Seleccionar región y editarla |
| Shift + Print | Copiar la pantalla |
| Ctrl + Print | Capturar y editar la ventana activa |

## Plasma Polkit y KWallet

Hyprland inicia `plasma-polkit-agent.service`, por lo que las solicitudes de
privilegios conservan el diálogo de Plasma. No ejecutes simultáneamente
`hyprpolkitagent`: Polkit debe tener un solo agente gráfico por sesión.

`plasma-kwallet-pam.service` entrega a KWallet las credenciales capturadas por
PAM durante el inicio de sesión. `kwallet-pam` puede desbloquear la cartera cuando
la contraseña de la cartera coincide con la contraseña del usuario. Después de
instalarlo, abre KWalletManager, selecciona la cartera `kdewallet` y comprueba
que use la misma contraseña de tu cuenta.

## Fondo de pantalla

Hyprpaper arranca sin imponer una imagen. Configúrala así:

```bash
~/.config/hypr/scripts/set-wallpaper.sh ~/Imágenes/fondo.jpg
```

La ruta elegida se guarda en `$XDG_STATE_HOME/hyprland/wallpaper` (o
`~/.local/state/hyprland/wallpaper`) y se restaura en cada inicio de Hyprland.
Este archivo es local a la máquina y no ensucia el repositorio.

## Temas

Dracula es el tema de Orion. La paleta de Quickshell está centralizada en `quickshell/Theme.qml` y la configuración de Hyprland correspondiente en `themes/dracula.lua`.

La estética de Orion sigue el lenguaje Material 3 de DankMaterialShell: barra flotante, superficies tonales, pills, tarjetas grandes, paneles elevados, jerarquía tipográfica y animaciones suaves. DMS es la referencia visual, no una dependencia ni código copiado.

## Organización

```text
hyprland.lua           Entrada mínima
lua/                   Módulos de Hyprland
themes/                Paletas compartidas
quickshell/             Orion Shell
  components/           Primitivas visuales reutilizables
  modules/              Launcher, barra, dashboard, centro de control, actividad,
                        monitor, ajustes y paneles funcionales
  services/             Estado reactivo del sistema
scripts/               Utilidades del escritorio
hyprlock.conf           Pantalla de bloqueo
hypridle.conf           Inactividad y suspensión
hyprpaper.conf          Fondo
```

## Actualización

```bash
cd ~/.local/src/hyprland_config
git pull --ff-only
~/.config/hypr/scripts/orionctl reload
```

No ejecutes `qs` manualmente si Orion ya está iniciado por UWSM. Eso crea dos shells y, como suele ocurrir con Linux, ambas creen que son la legítima.


## Arquitectura de Orion Shell

Orion concentra la interfaz en Quickshell y mantiene Hyprland/Lua como motor del escritorio. La estética completa usa un único sistema visual Material 3 inspirado en DankMaterialShell:

```text
Hyprland / Lua
      │
      ▼
Orion Shell / Quickshell
 ├── Core visual
 │   ├── Theme
 │   ├── Surface
 │   ├── Card
 │   └── controles reutilizables
 ├── Modules
 │   ├── Bar
 │   ├── Dashboard
 │   ├── Control Center
 │   ├── Media
 │   ├── Notifications
 │   └── Clipboard
 └── Services
     ├── SystemStatus
     └── NotificationService
```

La shell ya incluye una primera implementación completa de sus superficies principales:

- `Launcher.qml`: lanzador nativo basado en archivos `.desktop`.
- `Dashboard.qml`: resumen de sistema, conectividad, energía y almacenamiento.
- `ControlCenter.qml`: audio, brillo, Wi-Fi, Bluetooth, luz nocturna, perfiles de energía y dispositivos PipeWire.
- `ActivityCenter.qml`: notificaciones, portapapeles y acciones de sesión.
- `SystemMonitor.qml`: CPU, GPU, memoria, almacenamiento y procesos.
- `SettingsPanel.qml`: accesos de personalización, fondo, pantalla, red, Bluetooth y audio.
- `Tray.qml`: bandeja de sistema.
- `NotificationToast.qml`: avisos emergentes.


## Control por CLI

Orion expone sus módulos por IPC. El wrapper `orionctl` simplifica el acceso:

```bash
~/.config/hypr/scripts/orionctl launcher
~/.config/hypr/scripts/orionctl dashboard
~/.config/hypr/scripts/orionctl control
~/.config/hypr/scripts/orionctl notifications
~/.config/hypr/scripts/orionctl clipboard
~/.config/hypr/scripts/orionctl monitor
~/.config/hypr/scripts/orionctl settings
~/.config/hypr/scripts/orionctl session
~/.config/hypr/scripts/orionctl reload
```

## Superficies de Orion

```text
Bar
├── Launcher
├── Dashboard
├── Workspaces
├── ActiveWindow
├── Clock
├── Media
├── SystemMonitor
├── ControlCenter
├── ActivityCenter
├── Tray
└── Settings

Panels
├── Launcher
├── Dashboard
├── Control Center
├── Activity Center
│   ├── Notifications
│   ├── Clipboard
│   └── Session
├── System Monitor
└── Settings
```
