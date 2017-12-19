require 'minitest/autorun'
require 'minitest/pride'

class Node
  attr_accessor :id, :i, :j

  def self.next_id
    @id ||= 0
    @id += 1
  end

  def self.reset
    @id = 0
  end

  def initialize(i,j, grid)
    @i = i
    @j = j
    @id = Node.next_id
    @grid = grid
  end

  def index
    id - 1
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

  def north
    @grid&.value(i + 1, j)
  end

  def south
    @grid&.value(i - 1, j)
  end

  def north_east
    @grid&.value(i + 1, j - 1)
  end

  def south_east
    @grid&.value(i, j - 1)
  end

  def south_west
    @grid&.value(i - 1, j + 1)
  end

  def north_west
    @grid&.value(i, j + 1)
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
  
  attr_reader :adj_matrix,
              :data,
              :shortest_paths

  def initialize(walk)
    Node.reset
    @walk = walk.split(",")

    @data = {}
    build_grid
    build_adj_matrix
    @shortest_paths = run_dijkstra(start_node)

    @current_node = start_node
    perform_tour
  end

  def perform_tour
    @walk.each do |direction|
      @current_node = case direction
      when 'n'
        @current_node.north
      when 'ne'
        @current_node.north_east
      when 'se'
        @current_node.south_east
      when 's'
        @current_node.south
      when 'sw'
        @current_node.south_west
      when 'nw'
        @current_node.north_west
      end
    end
  end

  def start_node
    value(0, 0)
  end

  def distance
    @shortest_paths[@current_node.index]
  end

  def nodes
    @data.values
  end

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

  def build_adj_matrix
    vertex_count = nodes.count

    @adj_matrix = NxNMatrix.new(vertex_count)

    nodes.each do |node|
      node.neighbors.each do |neighbor|
        @adj_matrix.set(1, node.index, neighbor.index)
      end
    end
  end

  def build_grid
    n = 10 # make it always an even number

    n.times do |index_i|
      i = index_i - n / 2
      n.times do |index_j|
        j =  index_j - n / 2
        set(Node.new(i,j, self), i,j)
      end
    end
  end

  def value(i,j)
    @data[key(i,j)]
  end

  def set(node, i,j)
    @data[key(i,j)] = node
  end

  def key(i,j)
    "#{i}:#{j}"
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
    assert_equal(2, hg.distance)
  end

  def test_walk4
    hg = HexGrid.new("se,sw,se,sw,sw")
    assert_equal(3, hg.distance)
  end
end
