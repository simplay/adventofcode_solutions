require 'minitest/autorun'
require 'minitest/pride'

class SpiralMemory2
  Pos2 = Struct.new(:x, :y) do
    def key
      "#{x}:#{y}"
    end

    # exclude our position
    def neighbor_positions
      [
        as_key(x - 1, y),
        as_key(x + 1, y),
        as_key(x    , y + 1),
        as_key(x - 1, y + 1),
        as_key(x + 1, y + 1),
        as_key(x    , y - 1),
        as_key(x - 1, y - 1),
        as_key(x + 1, y - 1)
      ]
    end

    def as_key(x, y)
      "#{x}:#{y}"
    end
  end

  Item = Struct.new(:value, :pos2) do
    def distance
      pos2.x.abs + pos2.y.abs
    end
  end

  def initialize(number)
    @number = number
    @matrix = {}

    # positions
    @x = 0; @y = 0

    # maximal number of steps allowed in current direction in current turn
    @max_steps_in_dir = 1

    # number of steps of a half spiral iteration
    @steps_of_half_spin = @max_steps_in_dir * 2

    # number of steps in current direction
    @steps = 0

    # true if we are moving up or to the right
    # false if we are moving down or to the left
    @move_right_or_up = true

    # center weight
    @matrix["0:0"] = 1

    # interprete sequence as some kind of ordered list
    iter = 1
    items = []
    loop do
      pos = next_position
      weight = neighborhood_sum(pos)
      @matrix[pos.key] = weight
      items << Item.new(weight, pos)
      break if weight > number
    end

    # position of last item only matters
    @item = items.last
  end

  def neighborhood_sum(pos)
    sum = 0
    pos.neighbor_positions.each do |neighbor_pos|
      sum += @matrix[neighbor_pos] || 0
    end
    sum
  end

  # Sequence
  # 1 1 2 2 3 3 4 4 ...
  # r u l d r u l d ...
  def next_position

    # change the direction when the number of a half spin
    # has been walked. Also increase the number of steps
    # in the next turn accordingly.
    if @steps_of_half_spin == 0
      @max_steps_in_dir += 1
      @steps_of_half_spin = 2 * @max_steps_in_dir
      @move_right_or_up = !@move_right_or_up
      @steps = 0
    end
    @steps_of_half_spin -= 1

    if @move_right_or_up
      if @steps < @max_steps_in_dir
        @x += 1
        @steps += 1
      else
        # up
        @y += 1
      end
      Pos2.new(@x, @y)
    else
      if @steps < @max_steps_in_dir
        # left
        @x -= 1
        @steps += 1
      else
        # down
        @y -= 1
      end
      Pos2.new(@x, @y)
    end
  end

  def distance
    @item.value
  end
end

class SpiralMemoryTest < MiniTest::Test
  def test_dist1
    assert_equal(1, SpiralMemory2.new(0).distance)
  end

  def test_dist2
    assert_equal(2, SpiralMemory2.new(1).distance)
  end

  def test_dist3
    assert_equal(25, SpiralMemory2.new(23).distance)
  end

  def test_dist4
    assert_equal(747, SpiralMemory2.new(362).distance)
  end
end

number = 325489
distance = SpiralMemory2.new(number).distance
puts "The distance is: #{distance}"
