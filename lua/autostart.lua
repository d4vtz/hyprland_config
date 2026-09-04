-- UWSM coloca cada proceso dentro de la sesión gráfica y limpia al salir.
hl.on("hyprland.start", function()
    -- Reutiliza el diálogo nativo de Plasma para las solicitudes de Polkit.
    hl.exec_cmd("systemctl --user start plasma-polkit-agent.service")
    -- Entrega a KWallet las credenciales que pam_kwallet5 recibió de SDDM.
    hl.exec_cmd("systemctl --user start plasma-kwallet-pam.service")
    -- Quickshell sustituye a Waybar; scripts/bar-waybar.sh permite volver temporalmente.
    hl.exec_cmd("uwsm app -- qs")
    -- Quickshell recibe notificaciones; cliphist conserva el historial del portapapeles.
    hl.exec_cmd("uwsm app -- wl-paste --watch cliphist store")
    hl.exec_cmd("uwsm app -- hyprpaper")
    -- Espera al IPC de Hyprpaper y recupera el último fondo elegido.
    hl.exec_cmd("uwsm app -- ~/.config/hypr/scripts/restore-wallpaper.sh")
    hl.exec_cmd("uwsm app -- hypridle")
end)
