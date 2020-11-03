local RingBuffer = {}

--# Constants

RingBuffer.cap_size = 1000 + 1

--# Helpers

local function normalize_index(ring_buffer, index)
    return (index - 1) % ring_buffer.cap_size + 1
end

local function compute_actual_index(ring_buffer, index)
    assert(1 <= index and index <= ring_buffer:get_size(), 'index not in range')
    return normalize_index(ring_buffer, ring_buffer.start_index + index - 1)
end

--# Interface

function RingBuffer:initialize(maximum_size)
    self.cap_size = maximum_size + 1
    self.start_index = 1
    self.end_index = 1
    self.table = {}
end

function RingBuffer:get_element_at(index)
    return self.table[compute_actual_index(self, index)]
end

function RingBuffer:set_element_at(index, new_value)
    local actual_index = compute_actual_index(self, index)
    self.table[actual_index] = new_value
end

function RingBuffer:get_size()
    return (self.end_index - self.start_index) % self.cap_size
end

function RingBuffer:get_maximum_size()
    return self.cap_size - 1
end

function RingBuffer:is_empty()
    return self.start_index == self.end_index
end

function RingBuffer:push(new_element)
    self.table[self.end_index] = new_element
    self.end_index = normalize_index(self, self.end_index + 1)

    if self.end_index == self.start_index then
        self.start_index = normalize_index(self, self.start_index + 1)
    end
end

function RingBuffer:pop()
    assert(not self:is_empty(), 'empty')
    local pop_index = normalize_index(self, self.end_index - 1)
    local result = self.table[pop_index]
    self.table[pop_index] = nil
    self.end_index = pop_index
    return result
end

--#

return augment(RingBuffer)
