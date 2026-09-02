hl.window_rule({
    name = "suppress-maximize",
    match = { class = ".*" },
    suppress_event = "maximize",
})

hl.window_rule({
    name = "float-modal-dialogs",
    match = { modal = true },
    float = true,
    center = true,
})

hl.window_rule({
    name = "float-kcalc",
    match = { class = "^org.kde.kcalc$" },
    float = true,
    center = true,
})

hl.window_rule({
    name = "float-hyprpolkitagent",
    match = { class = "^hyprpolkitagent$" },
    float = true,
    center = true,
    size = { 520, 260 },
    dim_around = true,
    stay_focused = true,
})

hl.window_rule({
    name = "fix-xwayland-drag",
    match = {
        class = "^$",
        title = "^$",
        xwayland = true,
        float = true,
        fullscreen = false,
        pin = false,
    },
    no_focus = true,
})

-- Desenfoque para las superficies semitransparentes del escritorio.
for _, namespace in ipairs({ "waybar", "rofi", "swaync-control-center", "swaync-notification-window" }) do
    hl.layer_rule({
        name = "blur-" .. namespace,
        match = { namespace = "^" .. namespace .. "$" },
        blur = true,
        ignore_alpha = 0.2,
    })
end
