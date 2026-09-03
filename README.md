# Hyprland Configuration

Escritorio Hyprland modular para Arch Linux, escrito en Lua y probado con
Hyprland 0.56.2. Está diseñado para una pantalla 1920×1200, trabajo con código,
LaTeX, PDF, Xournal++ y multimedia.

## Diseño

- Configuración de Hyprland completamente en Lua.
- Tema Dracula desacoplado y preparado para añadir otras paletas.
- Layout master con siete espacios persistentes.
- Quickshell superior, modular y animada, con reloj centrado.
- Rofi como lanzador, SwayNC como centro de notificaciones.
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
  waybar rofi swaync hyprpaper hyprlock hypridle \
  satty grim slurp wl-clipboard cliphist jq cava \
  brightnessctl playerctl pavucontrol network-manager-applet \
  pipewire wireplumber qt5-wayland qt6-wayland \
  kitty dolphin ttf-jetbrains-mono-nerd
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
mv ~/.config/waybar ~/.config/waybar.backup 2>/dev/null || true
mv ~/.config/quickshell ~/.config/quickshell.backup 2>/dev/null || true
mv ~/.config/rofi ~/.config/rofi.backup 2>/dev/null || true
mv ~/.config/swaync ~/.config/swaync.backup 2>/dev/null || true
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
| Super + Espacio | Abrir Rofi |
| Super + Enter | Abrir Kitty |
| Super + E | Abrir Dolphin |
| Super + B | Abrir navegador |
| Super + N | Abrir SwayNC |
| Super + Escape | Menú de energía |
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

## Temas

Dracula es el tema inicial. Quickshell concentra su paleta en
`quickshell/Theme.qml`; el selector existente sincroniza Hyprland, la Waybar de
respaldo, Rofi, SwayNC y Hyprlock:

```bash
~/.config/hypr/scripts/theme-switch.sh dracula
```

Para añadir una paleta llamada nord, crea:

```text
themes/nord.lua
themes/nord.css
themes/nord.rasi
themes/nord-hyprlock.conf
```

y ejecuta theme-switch.sh nord.

## Organización

```text
hyprland.lua           Entrada mínima
lua/                   Módulos de Hyprland
themes/                Paletas compartidas
quickshell/             Shell principal y paneles QML
waybar/                 Barra anterior, conservada como fallback
rofi/                  Lanzador
swaync/                Notificaciones
scripts/               Utilidades del escritorio
hyprlock.conf           Pantalla de bloqueo
hypridle.conf           Inactividad y suspensión
hyprpaper.conf          Fondo
```

## Actualización

```bash
cd ~/.local/src/hyprland_config
git pull --ff-only
hyprctl reload
qs kill && uwsm app -- qs
swaync-client -R
swaync-client -rs
```

Durante la migración puedes alternar sin cerrar la sesión:

```bash
~/.config/hypr/scripts/bar-waybar.sh       # fallback
~/.config/hypr/scripts/bar-quickshell.sh  # volver a Quickshell
```
