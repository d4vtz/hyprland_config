#!/usr/bin/env bash
set -euo pipefail

bindings=$(
  printf '%s\n' \
    'SUPER + Enter                     Terminal' \
    'SUPER + E                         Archivos' \
    'SUPER + B                         Navegador' \
    'SUPER + Espacio                   Launcher de Caelestia' \
    'SUPER + X                         Portapapeles' \
    'SUPER + C                         Centro de control' \
    'SUPER + D                         Dashboard' \
    'SUPER + N                         Sidebar y notificaciones' \
    'SUPER + ,                         Ajustes de Caelestia' \
    'SUPER + Alt + P                   Selector de tema' \
    'SUPER + F1                        Panel de atajos' \
    'SUPER + L                         Bloquear sesión' \
    'SUPER + Escape                    Menú de sesión' \
    'SUPER + Q                         Cerrar ventana' \
    'SUPER + V                         Alternar flotante' \
    'SUPER + F                         Pantalla completa' \
    'SUPER + G                         Agrupar ventanas' \
    'SUPER + P                         Fijar sobre escritorios' \
    'SUPER + Y                         Alternar pseudotile' \
    'SUPER + Flechas                   Cambiar foco' \
    'SUPER + Shift + Flechas           Mover ventana' \
    'SUPER + Ctrl + Flechas            Redimensionar' \
    'SUPER + 1…7                       Cambiar escritorio' \
    'SUPER + Shift + 1…7               Mover ventana a escritorio' \
    'SUPER + Tab / Shift + Tab         Recorrer los siete escritorios' \
    'SUPER + PageUp / PageDown         Recorrer escritorios ocupados' \
    'SUPER + Ctrl + PageUp/PageDown    Recorrer todos los escritorios' \
    'SUPER + rueda                     Recorrer escritorios ocupados' \
    'SUPER + Ctrl + rueda              Recorrer todos los escritorios' \
    'SUPER + Alt + M/C/H/T/S           Abrir espacio especial' \
    'SUPER + Alt + Shift + letra       Enviar a espacio especial' \
    'SUPER + Alt + W                   Menú de espacios especiales' \
    'SUPER + arrastrar izquierdo       Mover ventana' \
    'SUPER + arrastrar derecho         Redimensionar ventana' \
    'Print                             Captura' \
    'Shift + Print                     Captura congelada' \
    'Ctrl + Print                      Selector de captura' \
    'SUPER + R                         Iniciar/detener grabación' \
    'Teclas multimedia                 Volumen, brillo y reproducción'
)

printf '%s\n' "$bindings" |
  rofi -dmenu -i -p 'Atajos de Orion' \
    -mesg 'Escribe para filtrar · Escape para cerrar' \
    -theme-str 'window { width: 62%; } listview { lines: 16; }'
