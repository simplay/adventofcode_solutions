class Dance
  attr_accessor :cursor,
                :programs,
                :n

  def initialize(moves, n=16)
    @moves = moves
    programs = []
    @n = n
    @cursor = 0
    @programs = %w(
      a b c d
      e f g h
      i j k l
      m n o p
    )
    @programs = @programs[0..n-1]
  end

  def execute
    @moves.each do |move|
      case move
      when /^s/
        x = move.split("s").last.to_i
        s(x)
      when /^x/
        a, b = move.gsub("x", '').split("/").map(&:to_i)
        x(a, b)
      when /^p/
        a, b = move.gsub(/^p/, '').split("/").map(&:strip)
        p(a, b)
      end
    end
  end

  def swap(idx1, idx2)
    tmp = programs[idx1]
    programs[idx1] = programs[idx2]
    programs[idx2] = tmp
  end

  def index_at(position:)
    (cursor + position) % n
  end

  def s(x)
    @cursor = (cursor - x) % n
  end

  # Make the programs at position a and b swap places
  #
  # @param a [Integer] position a
  # @param b [Integer] position b
  def x(a, b)
    pa = index_at(position: a)
    pb = index_at(position: b)
    swap(pa, pb)
  end

  # Makes the programs named A and B swap places
  #
  # @param a [String] name program a
  # @param b [String] name program b
  def p(a, b)
    pa = programs.index(a)
    pb = programs.index(b)
    swap(pa, pb)
  end

  def sequence
    s = programs[cursor..n-1]
    if cursor > 0
      s += programs[0..cursor-1]
    end
    s.join
  end
end

# part 1
sequence = File.read("data.txt").chomp.split(',')
d = Dance.new(sequence)
d.execute
puts "sequence: #{d.sequence}"

# part 2
d = Dance.new(sequence)
patterns = []
n = 1_000_000_000
n.times do |idx|
  d.execute
  seq = d.sequence
  if patterns.include?(seq)
    @m = idx
    break
  end
  patterns << seq
  puts "#{idx}: #{d.sequence}"
end

puts "running #{@m} iterations"
d = Dance.new(sequence)
(n % @m).times do
  d.execute
end

puts "sequence: #{d.sequence}"
