local utf8 = require'utf8'

return make_class{
    new = function (self)
        self.text = ''
    end,

    methods = {
        read = function (self)
            return self.text
        end,

        clear = function (self)
            self.text = ''
        end,

        append = function (self, text)
            self.text = self.text .. text
        end,

        backspace = function (self)
            local text = self.text

            if utf8.len(text) > 0 then
                self.text = text:sub(1, utf8.offset(text, -1) - 1)
            end
        end,
    },
}
