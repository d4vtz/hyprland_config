return function(settings)
    local mod = settings.mod
    local exec = hl.dsp.exec_cmd

    -- Aplicaciones y controles de sesión.
    hl.bind(mod .. " + RETURN", exec(settings.terminal))
    hl.bind(mod .. " + E", exec(settings.file_manager))
    hl.bind(mod .. " + B", exec(settings.browser))
    hl.bind(mod .. " + SPACE", exec(settings.menu))
    hl.bind(mod .. " + F1", exec("~/.config/hypr/scripts/keybinds-help.sh"))
    hl.bind(mod .. " + ESCAPE", exec("~/.config/hypr/scripts/powermenu.sh"))
    hl.bind(mod .. " + N", exec("swaync-client -t -sw"))

    hl.bind(mod .. " + Q", hl.dsp.window.close())
    hl.bind(mod .. " + V", hl.dsp.window.float({ action = "toggle" }))
    hl.bind(mod .. " + F", hl.dsp.window.fullscreen({ action = "toggle", mode = "fullscreen" }))
    hl.bind(mod .. " + SHIFT + F", hl.dsp.window.fullscreen({ action = "toggle", mode = "maximized" }))
    hl.bind(mod .. " + SHIFT + RETURN", hl.dsp.layout("swapwithmaster auto"))
    hl.bind(mod .. " + TAB", hl.dsp.layout("cyclenext loop"))

    local directions = {
        H = "left",
        J = "down",
        K = "up",
        L = "right",
        LEFT = "left",
        DOWN = "down",
        UP = "up",
        RIGHT = "right",
    }

    for key, direction in pairs(directions) do
        hl.bind(mod .. " + " .. key, hl.dsp.focus({ direction = direction }))
        hl.bind(mod .. " + SHIFT + " .. key, hl.dsp.window.swap({ direction = direction }))
    end

    -- Las flechas con Ctrl redimensionan el área principal.
    hl.bind(mod .. " + CTRL + LEFT", hl.dsp.layout("mfact -0.03"), { repeating = true })
    hl.bind(mod .. " + CTRL + RIGHT", hl.dsp.layout("mfact +0.03"), { repeating = true })
    hl.bind(mod .. " + CTRL + UP", hl.dsp.window.resize({ x = 0, y = -30, relative = true }), { repeating = true })
    hl.bind(mod .. " + CTRL + DOWN", hl.dsp.window.resize({ x = 0, y = 30, relative = true }), { repeating = true })

    for i = 1, settings.workspaces do
        hl.bind(mod .. " + " .. i, hl.dsp.focus({ workspace = i }))
        hl.bind(mod .. " + SHIFT + " .. i, hl.dsp.window.move({ workspace = i }))
    end

    hl.bind(mod .. " + S", hl.dsp.workspace.toggle_special("scratchpad"))
    hl.bind(mod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:scratchpad" }))
    hl.bind(mod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
    hl.bind(mod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))
    hl.bind(mod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
    hl.bind(mod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

    -- Capturas estilo Spectacle: región editable, pantalla y ventana activa.
    hl.bind("PRINT", exec("grimblast --notify edit area"), { locked = true })
    hl.bind("SHIFT + PRINT", exec("grimblast --notify copy output"), { locked = true })
    hl.bind("CTRL + PRINT", exec("grimblast --notify edit active"), { locked = true })

    hl.bind("XF86AudioRaiseVolume", exec("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
    hl.bind("XF86AudioLowerVolume", exec("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), { locked = true, repeating = true })
    hl.bind("XF86AudioMute", exec("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true })
    hl.bind("XF86AudioMicMute", exec("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), { locked = true })
    hl.bind("XF86MonBrightnessUp", exec("brightnessctl -e4 -n2 set 5%+"), { locked = true, repeating = true })
    hl.bind("XF86MonBrightnessDown", exec("brightnessctl -e4 -n2 set 5%-"), { locked = true, repeating = true })
    hl.bind("XF86AudioNext", exec("playerctl next"), { locked = true })
    hl.bind("XF86AudioPlay", exec("playerctl play-pause"), { locked = true })
    hl.bind("XF86AudioPause", exec("playerctl play-pause"), { locked = true })
    hl.bind("XF86AudioPrev", exec("playerctl previous"), { locked = true })
end
