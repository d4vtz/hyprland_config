return function(theme)
    hl.config({
        general = {
            gaps_in = 5,
            gaps_out = 8,
            border_size = 2,
            col = {
                active_border = { colors = { theme.purple, theme.pink }, angle = 45 },
                inactive_border = theme.current_line_alpha,
            },
            resize_on_border = true,
            extend_border_grab_area = 12,
            allow_tearing = false,
            layout = "master",
        },
        decoration = {
            rounding = 10,
            rounding_power = 2,
            active_opacity = 1.0,
            inactive_opacity = 1.0,
            shadow = {
                enabled = true,
                range = 8,
                render_power = 2,
                color = theme.shadow,
            },
            blur = {
                enabled = true,
                size = 5,
                passes = 2,
                vibrancy = 0.12,
                new_optimizations = true,
            },
        },
        misc = {
            force_default_wallpaper = 0,
            disable_hyprland_logo = true,
            disable_splash_rendering = true,
            focus_on_activate = true,
        },
    })

    -- Curvas rápidas: movimiento visible sin retrasar la interacción.
    hl.curve("fastOut", { type = "bezier", points = { { 0.22, 1 }, { 0.36, 1 } } })
    hl.curve("quick", { type = "bezier", points = { { 0.15, 0 }, { 0.1, 1 } } })
    hl.curve("smooth", { type = "spring", mass = 1, stiffness = 300, dampening = 30 })

    hl.animation({ leaf = "global", enabled = true, speed = 8, bezier = "fastOut" })
    hl.animation({ leaf = "windows", enabled = true, speed = 4, spring = "smooth" })
    hl.animation({ leaf = "windowsIn", enabled = true, speed = 3.5, spring = "smooth", style = "popin 92%" })
    hl.animation({ leaf = "windowsOut", enabled = true, speed = 3, bezier = "quick", style = "popin 92%" })
    hl.animation({ leaf = "border", enabled = true, speed = 5, bezier = "fastOut" })
    hl.animation({ leaf = "fade", enabled = true, speed = 4, bezier = "fastOut" })
    hl.animation({ leaf = "layers", enabled = true, speed = 4, bezier = "fastOut", style = "fade" })
    hl.animation({ leaf = "workspaces", enabled = true, speed = 4, spring = "smooth", style = "slide" })
end
