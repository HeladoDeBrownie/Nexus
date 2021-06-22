local Area = require'Area'
local Chunk = require'Chunk'
local Color = require'Color'
local ColorScheme = require'ColorScheme'
local Entity = require'Entity'
local EventSource = require'EventSource'
local Socket = require'socket'
local Sprite = require'Sprite'
local Host = require'Network/Host'
local SocketConnection = require'Network/SocketConnection'
local Visitor = require'Network/Visitor'

local Session = augment(mix{EventSource})

--# Constants

Session.DEFAULT_HOST = 'localhost'

-- This number represents the letters HELNX as typed out on a phone keypad,
-- which is short for "helado Nexus". The reason it's not NEXUS is because that
-- would give 63987, which is in the ephemeral ports range.
Session.DEFAULT_PORT = 43569

--# Interface

function Session:initialize()
    EventSource.initialize(self)

    self.area = Area:new(ColorScheme:new(
        Color:new(315,  15,  90),

        {
            Color:new(285,  30,  80),
            Color:new(255,  45,  70),
            Color:new(240,  60,  60),
        },

        {
            Color:new(180,  15,  90),
            Color:new(210,  45,  70),
            Color:new(240,  75,  50),
        }
    ))

    self.area:set_chunk(0, 0, Chunk:new())
    self.area:set_chunk(1, 1, Chunk:new())
    local file_name = 'Player Sprite.png'

    if love.filesystem.getInfo(file_name) == nil then
        file_name = 'Assets/Sprites/She.png'
    end

    self.player = Entity:new(Sprite.from_file(file_name))
    self.area:add_entity(self.player, 0, 0)
    self.status = 'offline'
end

function Session:get_area()
    return self.area
end

function Session:get_player()
    return self.player
end

function Session:get_status()
    return self.status
end

function Session:host(port)
    port = port or Session.DEFAULT_PORT
    local socket, error_reason = Socket.bind('*', port)

    if socket == nil then
        error(error_reason)
    else
        socket:settimeout(0)
        self.socket = socket
        self.host = Host:new()
        self.status = 'hosting'
    end
end

function Session:visit(host, port)
    host = host or Session.DEFAULT_HOST
    port = port or Session.DEFAULT_PORT
    local socket, error_reason = Socket.connect(host, port)

    if socket == nil then
        error(error_reason)
    else
        socket:settimeout(0)
        self.socket = socket
        self.visitor = Visitor:new(SocketConnection:new(socket))
        self.status = 'visiting'
    end
end

function Session:process()
    if self.status == 'hosting' then
        client_socket, error_reason = self.socket:accept()

        if client_socket ~= nil then
            client_socket:settimeout(0)
            self.host:connect(SocketConnection:new(client_socket))
        elseif error_reason ~= 'timeout' then
            error(error_reason)
        end

        self.host:process()
    elseif self.status == 'visiting' then
        self.visitor:process()
    end
end

function Session:quit()
    love.filesystem.write('Player Sprite.png',
        self:get_player():get_sprite():get_image_data():encode'png')
end

--#

return Session
