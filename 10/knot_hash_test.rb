require 'minitest/autorun'
require 'minitest/pride'

class Reducer
  attr_reader :reduced_sequence

  def initialize(lengths)
    @lengths = lengths

    text = lengths.join(",")
    transformed = AsciiCodeTransformer.new(text).transformed

    kh = KnotHash.new(transformed)
    @final_sequence = kh.run(64)
  end

  def reduce
    @reduced_sequence = @final_sequence.each_slice(16).map do |block|
      block.inject(0) { |sum, value| sum ^ value }
    end
  end

  def to_hex_string
    reduced_sequence.map do |seq| 
      seq.to_s(16) 
    end.join
  end
end

class AsciiCodeTransformer
  LOOKUP_TABLE = {
    "," => 44,
    "0" => 48,
    "1" => 49,
    "2" => 50,
    "3" => 51,
    "4" => 52,
    "5" => 53,
    "6" => 54,
    "7" => 55,
    "8" => 56,
    "9" => 57
  }

  STANDARD_SUFFIX = [17, 31, 73, 47, 23]

  attr_reader :transformed

  # assumption: text has only numbers and ,
  def initialize(text)
    
    transformed_text = text.chars.map do |char|
      LOOKUP_TABLE[char]
    end
    @transformed = transformed_text + STANDARD_SUFFIX
  end
end

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

  def run(repetitions = 1)
    repetitions.times do
      @length_index = 0
      lengths.each do |length|
        do_iteration
      end
    end
    @sequence
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

  def test_ascii_transformer
    text = [1,2,3].join(",")
    assert_equal(
      [49,44,50,44,51,17,31,73,47,23], 
      AsciiCodeTransformer.new(text).transformed
    )
  end
end

# part 1
lengths = [83,0,193,1,254,237,187,40,88,27,2,255,149,29,42,100]
kh = KnotHash.new(lengths)
kh.run
seq = kh.sequence

puts "checksum: #{seq[0] * seq[1]}"

# part 2
r = Reducer.new(lengths)
r.reduce
hash_value = r.to_hex_string
puts "hash value: #{hash_value}"
