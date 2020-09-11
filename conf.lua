function love.conf(configuration)
    require'deep_merge'(configuration, {
        accelerometerjoystick = false,
        appendidentity = true,
        gammacorrect = true,
        identity = 'helado_Nexus',

        modules = {
            font = false,
            physics = false,
            touch = false,
            video = false,
        },

        window = {
            resizable = true,
            title = "Nexus",
        },
    })
end
