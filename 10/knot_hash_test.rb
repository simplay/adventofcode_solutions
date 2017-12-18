require 'minitest/autorun'
require 'minitest/pride'

class KnotHash
  attr_reader :lengths,
              :sequence,
              :current_position,
              :current_length,
              :skip_size,
              :length_index

  # @param lengths [Array<Integer>]
  def initialize(lengths, max_value = 255)
    @max_value        = max_value
    @sequence         = (0..max_value).to_a
    @lengths          = lengths
    @current_position = 0
    @current_length   = 0
    @skip_size        = 0
    @length_index     = 0
  end

  def sequence_count
    @max_value + 1
  end

  # @param element_count [Integer] number of items to take
  #   starting from current position, assuming that the
  #   the data sequence is circular
  def selection_of(element_count:)
    (0..element_count - 1).map do |index|
      k = (current_position + index) % sequence_count
      @sequence[k]
    end
  end

  def update_list(sublist)
    (0..sublist.count - 1).each do |index|
      k = (current_position + index) % sequence_count
      @sequence[k] = sublist[index]
    end
  end

  def move_by
    current_length + skip_size
  end

  def do_iteration
    @current_length = lengths[length_index]
    @length_index += 1

    selection = selection_of(element_count: current_length)
    update_list(selection.reverse)
    @current_position = (@current_position + move_by) % sequence_count
    @skip_size += 1
  end

  def run
    lengths.each do |length|
      do_iteration
    end
  end

end

class KnotHashTest < MiniTest::Test
  def setup
    lengths = [3, 4, 1, 5]
    @kh = KnotHash.new(lengths, 4)
  end

  def kh
    @kh
  end

  def test_iterations
    kh.do_iteration
    assert_equal([2, 1, 0, 3, 4], kh.sequence)

    kh.do_iteration
    assert_equal([4, 3, 0, 1, 2], kh.sequence)

    kh.do_iteration
    assert_equal([4, 3, 0, 1, 2], kh.sequence)

    kh.do_iteration
    assert_equal([3, 4, 2, 1, 0], kh.sequence)
  end

  def test_run
    kh.run
    assert_equal([3, 4, 2, 1, 0], kh.sequence)
  end

  def test_checksum
    kh.run
    seq = kh.sequence
    assert_equal(12, seq[0] * seq[1])
  end

  def test_part1
    lengths = [83,0,193,1,254,237,187,40,88,27,2,255,149,29,42,100]
    kh = KnotHash.new(lengths)
    kh.run
    seq = kh.sequence
    assert_equal(20056, seq[0] * seq[1])
  end
end

lengths = [83,0,193,1,254,237,187,40,88,27,2,255,149,29,42,100]
kh = KnotHash.new(lengths)
kh.run
seq = kh.sequence

puts "checksum: #{seq[0] * seq[1]}"
