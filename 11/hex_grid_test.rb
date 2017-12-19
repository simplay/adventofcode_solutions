require 'minitest/autorun'
require 'minitest/pride'

class Node
  attr_accessor :north,
                :north_east,
                :south_east,
                :south,
                :south_west,
                :north_west,
                :id

  def initialize(graph)
    @id = Node.next_id
    @graph = graph
  end

  def neighbors
    [
      north,
      north_east,
      south_east,
      south,
      south_west,
      north_west
    ].compact
  end

  def index
    id - 1
  end

  def make_new_node(direction)
    # cases here, else
    #

    node = case direction
    when 'n'
    when 's'
    when 'sw'
    when 'se'
    when 'nw'
    when 'ne'
    else
      node = Node.new(@graph)
      @graph.add(node)
    end
  end

  def self.next_id
    @id ||= 0
    @id += 1
  end

  def self.reset
    @id = 0
  end

  def set_north(node)
    @north = node
    node.south = self
  end

  def set_north_east(node)
    @north_east = node
    node.south_west = self
  end

  def set_south_east(node)
    @south_east = node
    node.north_west = self
  end

  def set_south(node)
    @south = node
    node.north = self
  end

  def set_south_west(node)
    @south_west = node
    node.north_east = self
  end

  def set_north_west(node)
    @north_west = node
    node.south_east = self
  end

  def build_north
    set_north_west(make_new_node('nw')) unless north_west
    set_north(make_new_node('n')) unless north
    set_north_east(make_new_node('ne')) unless north_east

    north.set_south_east(north_east)
    north.set_south_west(north_west)
  end

  def build_north_east
    set_north(make_new_node('n')) unless north
    set_north_east(make_new_node('ne')) unless north_east
    set_south_east(make_new_node('se')) unless south_east

    north_east.set_north_west(north)
    north_east.set_south(south_east)
  end

  def build_south_east
    set_north_east(make_new_node('ne')) unless north_east
    set_south_east(make_new_node('se')) unless south_east
    set_south(make_new_nodem('s')) unless south

    south_east.set_north(north_east)
    south_east.set_south_west(south)
  end

  def build_south
    set_south_east(make_new_node('se')) unless south_east
    set_south(make_new_node('s')) unless south
    set_south_west(make_new_node('sw')) unless south_west

    south.set_north_east(south_east)
    south.set_north_west(south_west)
  end

  def build_south_west
    set_north_west(make_new_node('nw')) unless north_west
    set_south_west(make_new_node('sw')) unless south_west
    set_south(make_new_node('s')) unless south

    south_west.set_north(north_west)
    south_west.set_south_east(south)
  end

  def build_north_west
    set_north(make_new_node('n')) unless north
    set_north_west(make_new_node('nw')) unless north_west
    set_south_west(make_new_node('sw')) unless south_west

    north_west.set_south(south_west)
    north_west.set_north_east(north)
  end
end

class NxNMatrix
  def initialize(n)
    @data = (1..n).map do
      (1..n).map { 0 }
    end
  end

  def value(i, j)
    @data[i][j]
  end

  def set(value, i, j)
    @data[i][j] = value
  end
end

class HexGrid
  LARGE_INT_VALUE = 999_999_999_999

  attr_reader :nodes,
              :adj_matrix,
              :shortest_paths,
              :start_node

  def initialize(walk)
    Node.reset
    @nodes = []
    @walk = walk.split(",")
    @start_node = Node.new(self)
    @current_node = @start_node

    add(@start_node)

    build_graph
    build_adj_matrix
    @shortest_paths = run_dijkstra(@start_node)
  end

  def add(node)
    @nodes << node unless @nodes.include?(node)
  end

  def distance
    @shortest_paths[@current_node.index]
  end

  private

  def run_dijkstra(start)
    vertex_count = nodes.count

    # distances between a given :start and all other vertices
    distances = []

    # i-th element is true iff i-th vertex is included in shortest path
    shortest_path_set = []


    # Initialize distances and selections
    vertex_count.times do |i|
      distances << LARGE_INT_VALUE
      shortest_path_set << false
    end

    distances[start.index] = 0

    (vertex_count - 1).times do

      # get min node index u
      u = minimum_distance_vertex(distances, shortest_path_set)
      shortest_path_set[u] = true

      vertex_count.times do |v|
        if !shortest_path_set[v] &&
            adj_matrix.value(u,v) != 0 &&
            distances[u] != LARGE_INT_VALUE &&
            distances[u] + adj_matrix.value(u,v) < distances[v]

          distances[v] = distances[u] + adj_matrix.value(u,v)
        end
      end
    end
    distances
  end

  def minimum_distance_vertex(distances, shortest_path_set)
    min = LARGE_INT_VALUE
    min_index = -1

    vertex_count = nodes.count
    vertex_count.times do |idx|
      if !shortest_path_set[idx] && distances[idx] <= min
        min = distances[idx]
        min_index = idx
      end
    end

    min_index
  end

  # compute shortest distance between @start_node
  # and @current_node
  def build_adj_matrix
    # TODO
    vertex_count = nodes.count

    @adj_matrix = NxNMatrix.new(vertex_count)

    nodes.each do |node|
      node.neighbors.each do |neighbor|
        @adj_matrix.set(1, node.index, neighbor.index)
      end
    end
  end

  def build_graph
    @walk.each_with_index do |direction, idx|
      require 'pry'; binding.pry
      # @prev_node = @current_node

      case direction
      when 'n'
        next_node = @current_node.north
        @current_node.build_north unless next_node
        @current_node = @current_node.north

      when 'ne'
        next_node = @current_node.north_east
        @current_node.build_north_east unless next_node
        @current_node = @current_node.north_east

      when 'se'
        next_node = @current_node.south_east
        @current_node.build_south_east unless next_node
        @current_node = @current_node.south_east

      when 's'
        next_node = @current_node.south
        @current_node.build_south unless next_node
        @current_node = @current_node.south

      when 'sw'
        next_node = @current_node.south_west
        @current_node.build_south_west unless next_node
        @current_node = @current_node.south_west

      when 'nw'
        next_node = @current_node.north_west
        @current_node.build_north_west unless next_node
        @current_node = @current_node.north_west
      end

      add(@current_node)
    end
  end
end

class HexGridTest < MiniTest::Test
  def test_walk1
    hg = HexGrid.new("s,s,s")
    assert_equal(3, hg.distance)

    hg = HexGrid.new("n,n,n")
    assert_equal(3, hg.distance)

    hg = HexGrid.new("ne,ne,ne")
    assert_equal(3, hg.distance)

    hg = HexGrid.new("nw,nw,nw")
    assert_equal(3, hg.distance)

    hg = HexGrid.new("se,se,se")
    assert_equal(3, hg.distance)

    hg = HexGrid.new("sw,sw,sw")
    assert_equal(3, hg.distance)
  end

  def test_walk2
    hg1 = HexGrid.new("ne,ne,sw,sw")
    assert_equal(0, hg1.distance)

    hg1 = HexGrid.new("sw,sw,ne,ne")
    assert_equal(0, hg1.distance)

    hg = HexGrid.new("s,s,n,n")
    assert_equal(0, hg.distance)

    hg = HexGrid.new("n,n,s,s")
    assert_equal(0, hg.distance)

    hg = HexGrid.new("nw,nw,se,se")
    assert_equal(0, hg.distance)

    hg = HexGrid.new("se,se,nw,nw")
    assert_equal(0, hg.distance)
  end

  def test_walk3
    hg = HexGrid.new("ne,ne,s,s")
    require 'pry'; binding.pry
    assert_equal(2, hg.distance)
  end

  def test_walk4
    hg = HexGrid.new("se,sw,se,sw,sw")
    assert_equal(3, hg.distance)
  end
end
