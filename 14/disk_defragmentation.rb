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
  def initialize(value, row_idx, col_idx)
    @marked = false
    @value = value

    @row_idx = row_idx
    @col_idx = col_idx
  end

  def used?
    @value == "1"
  end

  def marked?
    @marked
  end

  def unmarked?
    !marked?
    # !@marked
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
      cells = row_values.map do |column|
        cell = Cell.new(
          column,
          row_idx,
          col_idx
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
    used_bits.find(&:visitable?)
  end

  def value(i,j)
    row = @data[i]
    return nil if row.nil?
    row[j]
  end

  def run
    parts = 0
    loop do
      start = new_start_bit
      return parts if start.nil?
      visit(start.row_idx, start.col_idx, parts)
      start.mark!
      parts += 1
    end
  end

  def visit(i, j, region)
    bit = value(i,j)
    bit.mark!
    bit.region = region

    visitable_children = [
      [i + 1, j],
      [i - 1, j],
      [i    , j + 1],
      [i    , j - 1]
    ].map do |p|
      value(p[0], p[1])
    end.compact.select(&:visitable?)
    

    visitable_children.each do |child|
        visit(child.row_idx, child.col_idx, region)
    end

    # down
    # if value(i + 1, j)&.visitable?
    #   visit(i + 1, j, region)
    #
    #   # up
    # elsif value(i - 1, j)&.visitable?
    #   visit(i - 1, j, region)
    #
    # # righ
    # elsif value(i, j + 1)&.visitable?
    #   visit(i, j + 1, region)
    #
    # # left
    # elsif value(i, j - 1)&.visitable?
    #   visit(i, j - 1, region)
    # end
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
end

# part 1
# generator_string = 'wenycdww'
generator_string = 'flqrgnkx'
# generator_string = "wenycdww"
defragmenter = Defragmenter.new(generator_string)
used_count = defragmenter.used_bits
puts "used bit count: #{used_count}"

m = Maze.new(defragmenter.bit_patterns)
c = m.run
require 'pry'; binding.pry
puts "regions: #{c}"
