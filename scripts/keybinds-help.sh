#!/usr/bin/env bash
set -euo pipefail

bindings=$(
  printf '%s\n' \
    'SUPER + Enter                 Abrir Kitty' \
    'SUPER + E                     Abrir Dolphin' \
    'SUPER + B                     Abrir navegador' \
    'SUPER + Espacio               Abrir Rofi' \
    'SUPER + F1                    Mostrar estos atajos' \
    'SUPER + Escape                Menú de energía' \
    'SUPER + N                     Centro de notificaciones' \
    'SUPER + Q                     Cerrar ventana' \
    'SUPER + V                     Alternar ventana flotante' \
    'SUPER + F                     Pantalla completa' \
    'SUPER + Shift + F             Maximizar' \
    'SUPER + H/J/K/L               Mover foco' \
    'SUPER + Flechas               Mover foco' \
    'SUPER + Shift + H/J/K/L       Intercambiar ventana' \
    'SUPER + Shift + Flechas       Intercambiar ventana' \
    'SUPER + Ctrl + Flechas        Redimensionar' \
    'SUPER + Shift + Enter         Intercambiar con ventana maestra' \
    'SUPER + Tab                   Recorrer ventanas' \
    'SUPER + 1…7                   Cambiar espacio de trabajo' \
    'SUPER + Shift + 1…7           Mover ventana a otro espacio' \
    'SUPER + PageUp/PageDown        Ciclo cerrado entre escritorios 1…7' \
    'SUPER + Ctrl + PageUp/PageDown Recorrer escritorios ocupados' \
    'SUPER + rueda                  Ciclo cerrado entre escritorios 1…7' \
    'SUPER + Ctrl + rueda           Recorrer escritorios ocupados' \
    'SUPER + S                     Mostrar scratchpad' \
    'SUPER + Shift + S             Enviar ventana al scratchpad' \
    'SUPER + arrastrar izquierdo   Mover ventana' \
    'SUPER + arrastrar derecho     Redimensionar ventana' \
    'Print                         Capturar y editar una región' \
    'Shift + Print                 Copiar la pantalla' \
    'Ctrl + Print                  Capturar y editar ventana activa'
)

printf '%s\n' "$bindings" |
  rofi -dmenu -i -p 'Atajos' -mesg 'Escribe para filtrar · Escape para cerrar' \
    -theme-str 'window { width: 58%; } listview { lines: 14; }'
