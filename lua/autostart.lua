-- UWSM coloca cada proceso dentro de la sesión gráfica y limpia al salir.
hl.on("hyprland.start", function()
    -- Reutiliza el diálogo nativo de Plasma para las solicitudes de Polkit.
    hl.exec_cmd("systemctl --user start plasma-polkit-agent.service")
    hl.exec_cmd("uwsm app -- waybar")
    hl.exec_cmd("uwsm app -- swaync")
    hl.exec_cmd("uwsm app -- hyprpaper")
    hl.exec_cmd("uwsm app -- hypridle")
end)
