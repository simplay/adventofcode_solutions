require 'minitest/autorun'
require 'minitest/pride'

class Debugger
  attr_reader :banks,
              :patterns

  def initialize(banks)
    @banks = banks
    @patterns = []
    save_current_bank_pattern
  end

  def save_current_bank_pattern
    patterns << pretty_bank
  end

  def cycles
    counter = 0
    loop do
      do_step
      counter += 1
      if patterns.include?(pretty_bank)
        return counter
      else
        save_current_bank_pattern
      end
    end
  end

  def do_step
    n = banks.count
    max_blocks = banks.max
    min_index_of_max_bank = banks.index(max_blocks)

    index_value = banks[min_index_of_max_bank]
    banks[min_index_of_max_bank] = 0

    index_value.times do |offset|
      current_index = (min_index_of_max_bank + 1 + offset) % n
      banks[current_index] += 1
    end
    banks
  end

  def pretty_bank
    banks.map(&:to_s).join(',')
  end

  # only after having detected a recursion
  def loop_size(matching_pattern)
    counter = 1
    loop do
      do_step
      return counter if pretty_bank == matching_pattern
      counter += 1
    end
  end
end

class DebuggerTest < MiniTest::Test
  def test_1
    banks = [0, 2, 7, 0]
    debugger = Debugger.new(banks)

    assert_equal(5, debugger.cycles)
    assert_equal("0,2,7,0", debugger.patterns[0])
    assert_equal("2,4,1,2", debugger.patterns[1])
    assert_equal("3,1,2,3", debugger.patterns[2])
    assert_equal("0,2,3,4", debugger.patterns[3])
    assert_equal("1,3,4,1", debugger.patterns[4])
  end

  def test_loop_size
    banks = [0, 2, 7, 0]
    debugger = Debugger.new(banks)
    debugger.cycles
    assert_equal(4, debugger.loop_size("2,4,1,2"))
  end
end

input = "5	1	10	0	1	7	13	14	3	12	8	10	7	12	0	6"
banks = input.split.map(&:to_i)

# part 1
debugger = Debugger.new(banks)
cycles = debugger.cycles
puts "cycles: #{cycles}"

# part 2
loop_size = debugger.loop_size(debugger.pretty_bank)
puts "loop_size: #{loop_size}"
