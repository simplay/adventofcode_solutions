require_relative '../10/knot_hash_test'

class Defragmenter
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

    bit_patterns = hash_values.map do |hash_value|
      bit_pattern = hash_value.chars.map do |char|
        char.to_i(16).to_s(2)
      end.map do |pattern|
        format('%04d', pattern)
      end
    end

    @used_count = bit_patterns.map do |bit_pattern|
      used_count = bit_pattern.join.split("").map(&:to_i).sum
    end.sum
  end

  def used_bits
    @used_count
  end
end

# part 1
generator_string = 'wenycdww'
used_count = Defragmenter.new(generator_string).used_bits
puts "used bit count: #{used_count}"
