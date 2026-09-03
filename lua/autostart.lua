-- UWSM coloca cada proceso dentro de la sesión gráfica y limpia al salir.
hl.on("hyprland.start", function()
    -- Reutiliza el diálogo nativo de Plasma para las solicitudes de Polkit.
    hl.exec_cmd("systemctl --user start plasma-polkit-agent.service")
    -- Entrega a KWallet las credenciales que pam_kwallet5 recibió de SDDM.
    hl.exec_cmd("systemctl --user start plasma-kwallet-pam.service")
    -- Quickshell sustituye a Waybar; scripts/bar-waybar.sh permite volver temporalmente.
    hl.exec_cmd("uwsm app -- qs")
    hl.exec_cmd("uwsm app -- swaync")
    hl.exec_cmd("uwsm app -- hyprpaper")
    hl.exec_cmd("uwsm app -- hypridle")
end)
