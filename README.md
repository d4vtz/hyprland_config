# Hyprland Configuration

Configuración personal de Hyprland para Arch Linux, escrita en Lua y probada con Hyprland 0.56.2.

## Entorno

- Arch Linux
- Hyprland 0.56.2
- Sesión administrada por UWSM
- Plasma Login Manager
- GPU Intel con controlador i915
- Kitty y Dolphin
- Distribución de teclado latinoamericana
- Diseño master
- Cinco espacios de trabajo

## Dependencias básicas

```text
hyprland
uwsm
xdg-desktop-portal-hyprland
qt5-wayland
qt6-wayland
hyprpolkitagent
pipewire
wireplumber
rtkit
brightnessctl
playerctl
kitty
dolphin
```

## Instalación

Clona el repositorio y enlaza la configuración:

```bash
git clone https://github.com/d4vtz/hyprland_config.git ~/.config/hypr
```

En Plasma Login Manager selecciona **Hyprland (uwsm-managed)**.

## Atajos principales

| Atajo | Acción |
|---|---|
| `Meta + Enter` | Abrir Kitty |
| `Meta + E` | Abrir Dolphin |
| `Meta + R` | Abrir Hyprlauncher |
| `Meta + Q` | Cerrar ventana |
| `Meta + Shift + Q` | Cerrar Hyprland |
| `Meta + H/J/K/L` | Cambiar foco |
| `Meta + Shift + H/J/K/L` | Intercambiar ventanas |
| `Meta + Shift + Enter` | Intercambiar con la ventana maestra |
| `Meta + Tab` | Recorrer ventanas |
| `Meta + Ctrl + ←/→` | Ajustar el área maestra |
| `Meta + F` | Pantalla completa |
| `Meta + V` | Alternar ventana flotante |
| `Meta + 1…5` | Cambiar de espacio |
| `Meta + Shift + 1…5` | Mover ventana a otro espacio |
| `Meta + S` | Mostrar scratchpad |
| `Meta + Shift + S` | Enviar ventana al scratchpad |

## Estado

Configuración base en desarrollo. Plasma permanece disponible como sesión alternativa.
