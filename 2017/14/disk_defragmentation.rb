require_relative '../10/knot_hash_test'

# RubyVM::InstructionSequence.compile_option = {
#   tailcall_optimization: true,
#   trace_instruction: false
# }

class Defragmenter
  attr_reader :bit_patterns

  def initialize(generator_string)
    key_strings = []
    128.times do |idx|
      key_strings << "#{generator_string}-#{idx}"
    end

    hash_values = key_strings.map do |key_string|
      reducer = Reducer.new(key_string, false)
      reducer.reduce
      reducer.to_hex_string
    end

    @bit_patterns = hash_values.map do |hash_value|
      bit_pattern = hash_value.chars.map do |char|
        char.to_i(16).to_s(2)
      end.map do |pattern|
        format('%04d', pattern)
      end
    end

    @used_count = @bit_patterns.flat_map do |bit_pattern|
      used_count = bit_pattern.join.split("").map(&:to_i)
    end.inject(0) do |sum,i| sum += i end
  end

  def used_bits
    @used_count
  end
end

class Cell
  attr_reader :row_idx, :col_idx
  attr_accessor :region
  def initialize(maze:, value:, row_idx:, col_idx:)
    @marked = false
    @value = value
    @maze = maze

    @row_idx = row_idx
    @col_idx = col_idx
  end

  def value(i,j)
    @maze.value(i,j)
  end

  def neighbors
    n = []
    if row_idx + 1 <= 127 && row_idx + 1 >= 0
        n << value(row_idx + 1, col_idx)
    end

    if row_idx - 1 <= 127 && row_idx - 1 >= 0
      n << value(row_idx - 1, col_idx)
    end

    if col_idx + 1 <= 127 && col_idx + 1 >= 0
      n << value(row_idx, col_idx + 1)
    end

    if col_idx - 1 <= 127 && col_idx - 1 >= 0
      n << value(row_idx, col_idx - 1)
    end

    n.compact.select(&:used?)
  end

  def used?
    @value == "1"
  end

  def marked?
    @marked
  end

  def unmarked?
    !marked?
  end

  def visitable?
    unmarked? && used?
  end

  def mark!
    @marked = true
  end

  def to_region
    return "." unless used?
    @region || "?"
  end

  def visited?
    marked? || !used?
  end
end

class Maze
  attr_reader :used_bits,
              :data

  def initialize(structure)
    row_idx = 0
    @data = structure.map(&:join).map do |s|
      row_values = s.split("")
      col_idx = 0
      cells = row_values.map do |column_value|
        cell = Cell.new(
          maze: self,
          value: column_value,
          row_idx: row_idx,
          col_idx: col_idx,
        )
        col_idx += 1
        cell
      end

      row_idx += 1
      cells
    end

    @used_bits = @data.flatten.select(&:used?)
  end

  def new_start_bit
    used_bits.find do |k| k.visitable? && k.region.nil? end
  end

  def value(i, j)
    row = @data[i]
    return nil if row.nil?
    row[j]
  end

  def run
    parts = 0
    loop do
      start = new_start_bit
      return parts if start.nil?
      visited = []
      visit(start.row_idx, start.col_idx, parts, visited)
      parts += 1
    end
  end

  def visit(i, j, region, visited)
    bit = value(i,j)
    bit.mark!
    bit.region = region
    visited << bit

    bit.neighbors.each do |child|
      unless visited.include?(child)
        visit(child.row_idx, child.col_idx, region, visited)
      end
    end
  end

  def print(num = 8)
    @data.first(num).each do |r|
      r.first(num).each do |c|
        printf format('% 4s', c.to_region)
      end
      puts ""
    end
    nil
  end

  def printsq(num: 8, right: 127, bottom: 127)
    t1 = right - num
    t2 = bottom - num
    @data[t1..right].each do |r|
      r[t2..bottom].each do |c|
        printf format('% 5s', c.to_region)
      end
      puts ""
    end
    nil
  end
end

# part 1
# generator_string = 'flqrgnkx'
generator_string = "wenycdww"
defragmenter = Defragmenter.new(generator_string)
used_count = defragmenter.used_bits
puts "used bit count: #{used_count}"

m = Maze.new(defragmenter.bit_patterns)
c = m.run
puts "regions: #{c}"
