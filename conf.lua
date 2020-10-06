function love.conf(configuration)
    require'Modules/deep_merge'(configuration, {
        version = '11.3',
        identity = 'helado de brownie_Nexus',
        accelerometerjoystick = false,
        gammacorrect = true,

        modules = {
            physics = false,
        },

        window = {
            title = 'Nexus',
            icon = 'Assets/Icon.png',
            width = 960, height = 640,
            resizable = true,
        },
    })
end
