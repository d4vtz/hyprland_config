-- UWSM coloca cada proceso dentro de la sesión gráfica y limpia al salir.
hl.on("hyprland.start", function()
    -- Reutiliza el diálogo nativo de Plasma para las solicitudes de Polkit.
    hl.exec_cmd("systemctl --user start plasma-polkit-agent.service")
    -- Entrega a KWallet las credenciales que pam_kwallet5 recibió de SDDM.
    hl.exec_cmd("systemctl --user start plasma-kwallet-pam.service")
    -- Dracula es el esquema inicial; el selector puede cambiarlo durante la sesión.
    hl.exec_cmd("caelestia scheme set -n dracula -f medium -m dark")
    -- Caelestia es el núcleo visual del fork Orion.
    hl.exec_cmd("caelestia shell -d")
    -- Caelestia recibe notificaciones; cliphist conserva texto e imágenes.
    hl.exec_cmd("uwsm app -- wl-paste --watch cliphist store")
    hl.exec_cmd("uwsm app -- wl-paste --type image --watch cliphist store")
    hl.exec_cmd("uwsm app -- hypridle")
end)
