
class Vertex
  attr_reader :neighbors, :id

  def initialize(id)
    @id = id
    @neighbors = []
    @marked = false
  end

  def mark!
    @marked = true
  end

  def marked?
    @marked
  end

  def connect(vertex)
    @neighbors << vertex unless @neighbors.include?(vertex)
    vertex.neighbors << self unless vertex.neighbors.include?(self)
  end
end

inputs = [
  "0 <-> 2",
  "1 <-> 1",
  "2 <-> 0, 3, 4",
  "3 <-> 2, 4",
  "5 <-> 6",
  "4 <-> 2, 3, 6",
  "6 <-> 4, 5",
]
inputs = File.read("data.txt").split("\n")

vertices = {}

inputs.each do |input|
  from, _ = input.split("<->").map(&:strip)
  vertices[from] = Vertex.new(from)
end

inputs.each do |input|
  # set edges
  from, tos = input.split("<->").map(&:strip)
  tos = tos.split(",").map(&:strip)

  from_node = vertices[from]
  tos.each do |to|
    to_node = vertices[to]
    from_node.connect(to_node)
  end
end

def dfs_traversal(r)
  stack = []
  stack.push(r)
  while(!stack.empty?)
    vertex = stack.pop
    unless vertex.marked?
      vertex.mark!
      vertex.neighbors.each do |neighbor|
        stack.push(neighbor) unless neighbor.marked?
      end
    end
  end
end

dfs_traversal(vertices["0"])

programs = vertices.values.select(&:marked?).map(&:id)

puts "program count: #{programs.count}"


counter = 0
start = "0"
until vertices.empty?
  dfs_traversal(vertices[start])
  programs = vertices.values.select(&:marked?).map(&:id)
  vertices = vertices.reject do |k, v| 
    programs.include?(k) 
  end
  start = vertices.keys.first
  counter += 1
end

puts "groups: #{counter}"
