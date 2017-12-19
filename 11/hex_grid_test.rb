require 'minitest/autorun'
require 'minitest/pride'

class HexGrid
  LARGE_INT_VALUE = 999_999_999_999
  
  attr_reader :furthest_dist

  def initialize(walk, n = 10)
    @walk = walk.split(",")

    @start_i = 0
    @start_j = 0

    @furthest_dist = -LARGE_INT_VALUE
    perform_tour
  end

  def perform_tour
    @walk.each do |direction|
      case direction
      when 'n'
        @start_i += 1
      when 'ne'
        @start_i += 1
        @start_j -= 1
      when 'se'
        @start_j -= 1
      when 's'
        @start_i -= 1
      when 'sw'
        @start_i -= 1
        @start_j += 1
      when 'nw'
        @start_j += 1
      end

      @furthest_dist = distance if distance >= @furthest_dist
    end
  end

  def distance
    @start_i.abs + @start_j.abs
  end
end

walk = File.read("data.txt").chomp
hg = HexGrid.new(walk, 3000)
# part 1
puts "dist: #{hg.distance}"

# part 2
puts "furthest dist: #{hg.furthest_dist}"
