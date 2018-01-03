class Cursor
  def initialize(start_x:, start_y:)
    @pos_x = start_x
    @pos_y = start_y
    @dir = :up
  end

  def position
    "#{@pos_x}:#{@pos_y}"
  end

  def turn_left
    @dir =
      case @dir
      when :up
        :left
      when :left
        :down
      when :down
        :right
      when :right
        :up
      end
  end

  def turn_right
    @dir =
      case @dir
      when :up
        :right
      when :right
        :down
      when :down
        :left
      when :left
        :up
      end
  end

  def reverse_direction
    @dir =
      case @dir
      when :up
        :down
      when :down
        :up
      when :left
        :right
      when :right
        :left
      end
  end

  def move
    case @dir
    when :up
      @pos_y -= 1
    when :right
      @pos_x += 1
    when :down
      @pos_y += 1
    when :left
      @pos_x -= 1
    end
  end
end

class Grid
  attr_reader :cursor, :burst_infect_count
  def initialize(initial_state)
    center = initial_state.first.count / 2
    @burst_infect_count = 0

    @infected_cells = {}
    initial_state.each_with_index do |row, row_idx|
      row.each_with_index do |cell, col_idx|
        # x := col_idx, y := row_idx
        key = "#{col_idx}:#{row_idx}"
        @infected_cells[key] = :infected if cell == "#"
      end
    end
    @cursor = Cursor.new(start_x: center, start_y: center)
  end

  def burst
    current_position = @infected_cells[@cursor.position]

    # is infected
    if current_position == :infected
      @cursor.turn_right
      clean(@cursor.position)
    else
      @cursor.turn_left
      @burst_infect_count += 1
      infect(@cursor.position)
    end

    @cursor.move
  end

  def clean(position)
    @infected_cells.delete(position)
  end

  def infect(position)
    @infected_cells[position] = :infected
  end
end

class AdvancedGrid < Grid
  def burst
    current_position = @infected_cells[@cursor.position]

    # is infected
    if current_position.nil?
      @cursor.turn_left
    elsif current_position == :infected
      @cursor.turn_right
    elsif current_position == :flagged
      @cursor.reverse_direction
    end
    update_state(@cursor.position, current_position)
    @cursor.move
  end

  def update_state(position, state)
    case state
    when :infected
      @infected_cells[position] = :flagged
    when :flagged
      clean(position)
    when :weakened
      @infected_cells[position] = :infected
      @burst_infect_count += 1
    else
      @infected_cells[position] = :weakened
    end
  end
end

initial_state = File.open('map').read.split(/\n/)
initial_state = initial_state.map do |row|
  row.chars
end

# part 1
g = Grid.new(initial_state)
10_000.times do
  g.burst
end
puts g.burst_infect_count

# part 2
g = AdvancedGrid.new(initial_state)
10_000_000.times do |idx|
  g.burst
  puts "ITERATION #{idx + 1}" if idx % 100_000 == 0
end
puts g.burst_infect_count
