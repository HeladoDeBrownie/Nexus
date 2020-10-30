local Queue = {}

--# Interface

function Queue:initialize()
    self.table = {}
end

function Queue:is_empty()
    return self.table[1] == nil
end

function Queue:push(value)
    table.insert(self.table, value)
end

function Queue:pop()
    return table.remove(self.table, 1)
end

--#

return augment(Queue)
