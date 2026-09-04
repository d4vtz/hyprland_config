hl.config({
    input = {
        kb_layout = "latam",
        follow_mouse = 1,
        sensitivity = 0,
        repeat_rate = 35,
        repeat_delay = 250,
        touchpad = {
            natural_scroll = false,
            tap_to_click = true,
            disable_while_typing = true,
        },
    },
})

hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })
