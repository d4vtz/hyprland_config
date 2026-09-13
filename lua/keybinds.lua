return function(settings)
    local mod = settings.mod
    local exec = hl.dsp.exec_cmd

    hl.bind(mod .. " + RETURN", exec(settings.terminal))
    hl.bind(mod .. " + E", exec(settings.file_manager))
    hl.bind(mod .. " + B", exec(settings.browser))
    hl.bind(mod .. " + SPACE", hl.dsp.global("caelestia:launcher"))
    hl.bind(mod .. " + F1", exec("~/.config/hypr/scripts/keybinds-help.sh"))
    hl.bind(mod .. " + X", exec("~/.config/hypr/scripts/clipboard-menu.sh"))
    hl.bind(mod .. " + ALT + P", exec("~/.config/hypr/scripts/theme-selector.sh"))
    hl.bind(mod .. " + ALT + W", exec("~/.config/hypr/scripts/special-workspaces-menu.sh"))
    hl.bind(mod .. " + X", exec("~/.config/hypr/scripts/clipboard-menu.sh"))
    hl.bind(mod .. " + ALT + P", exec("~/.config/hypr/scripts/theme-selector.sh"))
    hl.bind(mod .. " + ALT + W", exec("~/.config/hypr/scripts/special-workspaces-menu.sh"))
    hl.bind(mod .. " + ESCAPE", hl.dsp.global("caelestia:session"))
    hl.bind(mod .. " + N", hl.dsp.global("caelestia:sidebar"))
    hl.bind(mod .. " + D", hl.dsp.global("caelestia:dashboard"))
    hl.bind(mod .. " + C", hl.dsp.global("caelestia:utilities"))
    hl.bind(mod .. " + COMMA", hl.dsp.global("caelestia:nexus"))
    hl.bind(mod .. " + L", hl.dsp.global("caelestia:lock"))

    hl.bind(mod .. " + Q", hl.dsp.window.close())
    hl.bind(mod .. " + V", hl.dsp.window.float({ action = "toggle" }))
    hl.bind(mod .. " + F", hl.dsp.window.fullscreen({ action = "toggle", mode = "fullscreen" }))
    hl.bind(mod .. " + G", hl.dsp.group.toggle())
    hl.bind(mod .. " + P", hl.dsp.window.pin())
    hl.bind(mod .. " + Y", exec("hyprctl dispatch pseudo"))

    local directions = { LEFT = "left", DOWN = "down", UP = "up", RIGHT = "right" }
    for key, direction in pairs(directions) do
        hl.bind(mod .. " + " .. key, hl.dsp.focus({ direction = direction }))
        hl.bind(mod .. " + SHIFT + " .. key, hl.dsp.window.move({ direction = direction }))
    end

    hl.bind(mod .. " + CTRL + LEFT", hl.dsp.layout("mfact -0.03"), { repeating = true })
    hl.bind(mod .. " + CTRL + RIGHT", hl.dsp.layout("mfact +0.03"), { repeating = true })
    hl.bind(mod .. " + CTRL + UP", hl.dsp.window.resize({ x = 0, y = -30, relative = true }), { repeating = true })
    hl.bind(mod .. " + CTRL + DOWN", hl.dsp.window.resize({ x = 0, y = 30, relative = true }), { repeating = true })

    for i = 1, settings.workspaces do
        hl.bind(mod .. " + " .. i, hl.dsp.focus({ workspace = i }))
        hl.bind(mod .. " + SHIFT + " .. i, hl.dsp.window.move({ workspace = i }))
    end

    local function cycle_workspace(step)
        return function()
            local current = hl.get_active_workspace().id
            local target = ((current - 1 + step) % settings.workspaces) + 1
            hl.dispatch(hl.dsp.focus({ workspace = target }))
        end
    end

    local function cycle_occupied_workspace(step)
        return function()
            local current = hl.get_active_workspace().id
            local occupied = {}
            for i = 1, settings.workspaces do
                if #hl.get_workspace_windows(i) > 0 then table.insert(occupied, i) end
            end
            if #occupied == 0 then return end
            local target = step > 0 and occupied[1] or occupied[#occupied]
            if step > 0 then
                for _, workspace in ipairs(occupied) do
                    if workspace > current then target = workspace break end
                end
            else
                for i = #occupied, 1, -1 do
                    if occupied[i] < current then target = occupied[i] break end
                end
            end
            hl.dispatch(hl.dsp.focus({ workspace = target }))
        end
    end

    hl.bind(mod .. " + TAB", cycle_workspace(1))
    hl.bind(mod .. " + SHIFT + TAB", cycle_workspace(-1))
    hl.bind(mod .. " + Page_Up", cycle_occupied_workspace(-1))
    hl.bind(mod .. " + Page_Down", cycle_occupied_workspace(1))
    hl.bind(mod .. " + CTRL + Page_Up", cycle_workspace(-1))
    hl.bind(mod .. " + CTRL + Page_Down", cycle_workspace(1))

    local special_workspaces = {
        M = "music", C = "communication", H = "sysmon", T = "todo", S = "scratchpad",
    }
    for key, workspace in pairs(special_workspaces) do
        hl.bind(mod .. " + ALT + " .. key, hl.dsp.workspace.toggle_special(workspace))
        hl.bind(mod .. " + ALT + SHIFT + " .. key, hl.dsp.window.move({ workspace = "special:" .. workspace }))
    end

    hl.bind(mod .. " + mouse_down", cycle_occupied_workspace(1))
    hl.bind(mod .. " + mouse_up", cycle_occupied_workspace(-1))
    hl.bind(mod .. " + CTRL + mouse_down", cycle_workspace(1))
    hl.bind(mod .. " + CTRL + mouse_up", cycle_workspace(-1))
    hl.bind(mod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
    hl.bind(mod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

    hl.bind("PRINT", exec("caelestia screenshot"), { locked = true })
    hl.bind("SHIFT + PRINT", hl.dsp.global("caelestia:screenshotFreeze"), { locked = true })
    hl.bind("CTRL + PRINT", hl.dsp.global("caelestia:screenshot"), { locked = true })
    hl.bind(mod .. " + R", exec("caelestia record"))

    hl.bind("XF86AudioRaiseVolume", exec("wpctl set-mute @DEFAULT_AUDIO_SINK@ 0; wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
    hl.bind("XF86AudioLowerVolume", exec("wpctl set-mute @DEFAULT_AUDIO_SINK@ 0; wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), { locked = true, repeating = true })
    hl.bind("XF86AudioMute", exec("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true })
    hl.bind("XF86AudioMicMute", exec("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), { locked = true })
    hl.bind("XF86MonBrightnessUp", hl.dsp.global("caelestia:brightnessUp"), { locked = true, repeating = true })
    hl.bind("XF86MonBrightnessDown", hl.dsp.global("caelestia:brightnessDown"), { locked = true, repeating = true })
    hl.bind("XF86AudioNext", hl.dsp.global("caelestia:mediaNext"), { locked = true })
    hl.bind("XF86AudioPlay", hl.dsp.global("caelestia:mediaToggle"), { locked = true })
    hl.bind("XF86AudioPause", hl.dsp.global("caelestia:mediaToggle"), { locked = true })
    hl.bind("XF86AudioPrev", hl.dsp.global("caelestia:mediaPrev"), { locked = true })
end
