function love.conf(configuration)
    require'deep_merge'(configuration, {
        accelerometerjoystick = false,
        appendidentity = true,
        gammacorrect = true,
        identity = 'helado_Nexus',

        window = {
            icon = 'Assets/Icon.png',
            resizable = true,
            title = "Nexus",
        },
    })
end
