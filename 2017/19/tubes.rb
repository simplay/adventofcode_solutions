class Map
  def initialize(filename)
    @data = File.read(filename).split(/\n/)
  end

  def value(row_idx, col_idx)
    row = @data[row_idx]
    return nil if row.nil?
    row[col_idx]
  end

  def set(value, row_idx, col_idx)
    row = @data[row_idx]
    return nil if row.nil?
    cell = row[col_idx]
    @data[row_idx][col_idx] = value unless cell.nil?
  end

  # @return col idx of start
  def start
    @data[0].index('|')
  end
end

class Tube
  attr_reader :map,
              :sequence,
              :steps

  attr_accessor :c_x,
                :c_y,
                :dir

  def initialize(filename)
    @dir = :down
    @map = Map.new(filename)

    # find start position
    @c_x = map.start
    @c_y = 0

    @steps = 0
    @sequence = ''
  end

  # get the map value at the current cursor position
  def cursor_value(row_idx: c_y, col_idx: c_x)
    map.value(row_idx, col_idx)
  end

  def update_position(dir)
    case dir
    when :left
      self.c_x -= 1
    when :right
      self.c_x += 1
    when :up
      self.c_y -= 1
    when :down
      self.c_y += 1
    end
  end

  def update_dir(dir)
    self.dir =
      case dir
      when :up, :down
        left = cursor_value(col_idx: c_x - 1)
        (left != " " && left != nil) ? :left : :right
      when :left, :right
        top = cursor_value(row_idx: c_y - 1)
        (top != " " && top != nil) ? :up : :down
      end
  end

  # @return [Boolean] true if last field was visit otherwise false.
  def step
    @steps += 1

    update_position(dir)

    case cursor_value
    when /\w/
      @sequence += cursor_value
    when '+'
      update_dir(dir)
    when /\s/
      return true
    end

    false
  end
end

filename = "test_data"
filename = "real_data"

tube = Tube.new(filename)

loop do
  is_done = tube.step
  break if is_done
end

# part 1
puts "sequence: #{tube.sequence}"

# part 2
puts "steps: #{tube.steps}"
