class Generator
  MAGIC_NUMBER = 2147483647
  BITS = 32

  attr_reader :value,
              :factor

  def initialize(factor:, start_value:)
    @factor = factor
    @start  = start_value
    @value  = @start
  end

  # overwrites previous value
  def next_value
    v = value * factor
    @value = v % MAGIC_NUMBER
  end

  def to_binary
    t = format("% #{BITS}d", value.to_s(2))
    t.gsub(/\s/, '0')
  end

  def right_16bits
    n = BITS - 1
    to_binary[n - 15..n]
  end

  def hit?(generator)
    right_16bits == generator.right_16bits
  end
end

n = 40_000_000

f_a = 16807
f_b = 48271

start_a = 65
start_b = 8921

hits = 0
g1 = Generator.new(factor: f_a, start_value: start_a)
g2 = Generator.new(factor: f_b, start_value: start_b)
n.times do |idx|
  g1.next_value
  g2.next_value

  hits += 1 if g1.hit? g2

  puts "Iteration #{idx + 1}: hits=#{hits}" if idx % 250_000 == 0
end

puts "hits: #{hits}"
