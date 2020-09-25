function love.conf(configuration)
    require'Modules/deep_merge'(configuration, {
        accelerometerjoystick = false,
        gammacorrect = true,
        identity = 'helado de brownie_Nexus',

        window = {
            icon = 'Assets/Icon.png',
            resizable = true,
            title = 'Nexus',
        },
    })
end
