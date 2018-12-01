class Item
  def initialize
  end
end

class Spinlock
  attr_reader :buffer
  attr_accessor :buffer_cursor

  def initialize(max_number:, steps:)
    @max_number = max_number
    @current_value = 0
    @steps = steps
    @buffer = [@current_value]
    @buffer_cursor = 0
  end

  def run
    @max_number.times do |idx|
      update_cursor
      insert_value
      @buffer_cursor += 1
    end
  end

  def value_after(value = 2017)
    buffer[buffer.index(value) + 1]
  end

  def insert_value
    @current_value += 1
    left = buffer[0..buffer_cursor]
    center = [@current_value]
    right = buffer[(buffer_cursor + 1)..-1]
    @buffer = left + center + right
  end

  def update_cursor
    @buffer_cursor = (@buffer_cursor + @steps) % buffer.count
  end
end

# part 1
spinlock_size = 301
sl = Spinlock.new(max_number: 2017, steps: spinlock_size)
sl.run
value = sl.value_after(2017)
puts "value: #{value}"

# part 2
buffer_cursor = 0
50_000_000.times do |idx|
  iter = idx + 1
  buffer_cursor = ((buffer_cursor + spinlock_size) % iter) + 1
  @result = iter if buffer_cursor == 1
end
puts "value. #{@result}"
