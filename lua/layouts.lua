-- Master favorece un editor principal y referencias secundarias.
hl.config({
    master = {
        new_status = "slave",
        new_on_top = false,
        orientation = "left",
        mfact = 0.62,
        focus_master_on_close = true,
        smart_resizing = true,
    },
    dwindle = {
        preserve_split = true,
        smart_split = false,
    },
})
