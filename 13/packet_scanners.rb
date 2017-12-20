class Layer
  attr_reader :depth

  def initialize(layer, depth)
    @layer = layer
    @depth = depth
    @index = 0
    @index_values =
      (0..depth-1).to_a + (1..depth-2).to_a.reverse
    @current_index_value = @index_values[@index]
  end

  def do_step
    @index = (@index + 1) % @index_values.count
    @current_index_value = @index_values[@index]
  end

  def cursor
    @current_index_value
  end

  def collision_at?(index)
    index == cursor
  end

  # check if current position + some delay modulo the number
  # of possible index values is not 0 (zero means, that we were detected)
  def is_not_hit?(start_time:)
    (@layer + start_time) % @index_values.count != 0
  end
end

record = %[
0: 4
1: 2
2: 3
4: 5
6: 6
8: 4
10: 8
12: 6
14: 6
16: 8
18: 8
20: 6
22: 8
24: 9
26: 8
28: 8
30: 12
32: 12
34: 10
36: 12
38: 12
40: 10
42: 12
44: 12
46: 12
48: 12
50: 12
52: 14
54: 14
56: 12
58: 14
60: 14
62: 14
64: 17
66: 14
70: 14
72: 14
74: 14
76: 14
78: 18
82: 14
88: 18
90: 14
]

# record = %[
#   0: 3
#   1: 2
#   4: 4
#   6: 4
# ]

class PacketScanner
  attr_reader :layers,
              :layer_count

  def initialize(recording)
    @record = recording.split("\n").map(&:strip).reject(&:empty?)
    @layer_count = @record.map do |s| 
      s.gsub(/:\s\d+/, '') 
    end.map(&:to_i).max + 1
    reset_layers
  end

  def reset_layers
    @layers = {}
    @record.each do |r|
      layer, depth = r.split(":")
      @layers[layer] = Layer.new(layer.to_i, depth.to_i)
    end
  end

  def severity
    sum = 0
    layer_count.times do |iter|
      layer = layers[iter.to_s]
      if layer&.collision_at? 0
        sum += iter * layer.depth
      end
      layers.values.each(&:do_step)
    end
    sum
  end

  def min_time
    delay = 0
    loop do
      ok = layers.values.all? { |layer| layer.is_not_hit?(start_time: delay) }
      return delay if ok

      puts delay if delay % 1000

      delay += 1
    end
  end
end

ps = PacketScanner.new(record)
sum = ps.severity
# part 1
puts "sum: #{sum}"

ps.reset_layers

# part 2
wait_time = ps.min_time
puts "wait time: #{wait_time}"
