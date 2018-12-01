# A rule defines a matchign patterns and how a match
# (resulting by flip and rotate operations) should be translated
# (by its substitution pattern)
class Rule
  attr_reader :state, :substitution

  def initialize(transformation)
    from, to = transformation.split('=>').map(&:strip)

    @state = transform(from)
    @substitution = transform(to)

    # transform the state of the initial matching pattern
    # by applying flip and rotation operations
    @patterns = [
      @state,
      flip_vertically,
      flip_horizontally,
      fh(s: flip_vertically),
      fv(s: flip_horizontally),
      rotate(rotations: 2),
      rotate(rotations: 1),
      rotate(rotations: 3),
      fv(s: rotate(rotations: 1)),
      fv(s: rotate(rotations: 2)),
      fv(s: rotate(rotations: 3)),
      fh(s: rotate(rotations: 1)),
      fh(s: rotate(rotations: 2)),
      fh(s: rotate(rotations: 3)),
    ].uniq
  end

  def transform(data)
    data.split("/").map do |row|
      row.chars.map do |c|
        c == '.' ? false : true
      end
    end
  end

  def rotate(s: @state, rotations: 0)
    tmp = s
    rotations.times do
      tmp = tmp.transpose.reverse
    end
    tmp
  end
  alias_method :r, :rotate

  def flip_horizontally(s: @state)
    s.reverse
  end
  alias_method :fh, :flip_horizontally

  def flip_vertically(s: @state)
    s.transpose
          .reverse
          .transpose
  end
  alias_method :fv, :flip_vertically

  def to_s
    @state.each do |row|
      d = row.map do |c| c ? '#' : '.' end.join(" ")
      puts d
    end
    puts
  end

  def match?(mask)
    @patterns.any? do |s|
      s == mask
    end
  end
end

class Grid
  attr_reader :rules

  ON  = '#'.freeze
  OFF = '.'.freeze

  def initialize(rules)
    @states = [
      [false, true,  false],
      [false, false, true],
      [true,  true,  true]
    ]

    @rules = rules
  end

  # @return [Boolean, nil]
  def value(row_idx, col_idx)
    row = @states[row_idx]
    return nil unless row
    row[col_idx]
  end

  def token(row_idx, col_idx)
    value(row_idx, col_idx) ? ON : OFF
  end

  def size
    @states.first.count
  end

  # @return [Array<Array<Boolean>>]
  def submatrix(index_range)
    row_idxs, col_idxs = index_range
    row_idxs.map do |row_idx|
      col_idxs.map do |col_idx|
        value(row_idx, col_idx)
      end
    end
  end

  # @return [Array<Array<Range,Range>>] Lookup ranges.
  #   Each range collection forms a sub-matrix, i.e. a cluster.
  #   E.g.
  #   [
  #     [0..2, 0..2],
  #     [0..2, 3..5],
  #     [0..2, 6..8],
  #     [3..5, 0..2],
  #     [3..5, 3..5],
  #     [3..5, 6..8],
  #     [6..8, 0..2],
  #     [6..8, 3..5],
  #     [6..8, 6..8]
  #   ]
  def lookup_indices(dim, factor)
    indices = dim.times.map { |i| (factor * i..factor * (i + 1) - 1) }
    indices.product(indices)
  end

  # build resized grid
  def build_new_grid(dim)
    new_fractal = []
    dim.times do
      tmp = []
      dim.times do
        tmp << false
      end
      new_fractal << tmp
    end

    new_fractal
  end

  def update
    is_even_dim = size % 2 == 0
    factor = is_even_dim ? 2 : 3
    dim = size / factor

    new_dim = dim * (factor + 1)
    new_fractal = build_new_grid(new_dim)

    indices = lookup_indices(dim, factor)
    transformed_indices = lookup_indices(dim, factor + 1)

    indices.each_with_index do |index_pair, index_counter|
      region = submatrix(index_pair)
      matching_rule = rules.find { |rule| rule.match?(region) }

      # indices of resized grid
      indices_resized_grid = transformed_indices[index_counter]
      indices_resized_grid[0].each_with_index do |row_idx, r_idx|
        indices_resized_grid[1].each_with_index do |col_idx, c_idx|

          # use local rule coordinates
          cell = matching_rule.substitution[r_idx][c_idx]

          # write into global (resized) coordinate system
          new_fractal[row_idx][col_idx] = cell
        end
      end
    end

    @states = new_fractal
    self
  end

  def to_s
    size.times do |row_idx|
      size.times do |col_idx|
        print token(row_idx, col_idx)
      end
      puts ''
    end
  end

  def count
    @states.flatten.count(true)
  end
end

data = File.open('rules').read.split(/\n/)

rules = data.map do |input|
  Rule.new(input)
end

g = Grid.new(rules)

18.times do |idx|
  print "ITERATION: #{idx + 1}: "
  g.update
  if idx + 1 == 5
    print "PART 1 INFO: #{g.count} pixels are on. "
  end

  print 'done'
  puts
end

puts "PART 2 INFO: #{g.count} pixels are on"
