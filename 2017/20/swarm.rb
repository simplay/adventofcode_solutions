class Point3
  attr_reader :x, :y, :z

  def initialize(x, y, z)
    @x = x; @y = y; @z = z
  end

  def l1_distance
    x.abs + y.abs + z.abs
  end

  def +(other)
    @x += other.x
    @y += other.y
    @z += other.z
    self
  end

  def to_s
    "<#{x},#{y},#{z}>"
  end
end

class Particle
  attr_reader :id, :position

  def initialize(id, position, velocity, acceleration)
    @id            = id
    @position      = position
    @velocity      = velocity
    @acceleration  = acceleration
  end

  def update
    @velocity = @velocity + @acceleration
    @position = @position + @velocity
    self
  end

  def position_string
    position.to_s
  end

  def distance
    @position.l1_distance
  end

  def to_s
    "#{id} => p=#{@position}, v=#{@velocity}, a=#{@acceleration}"
  end
end

filename = "test_data"
filename = "real_data"
particles_data = File.read(filename).split(/\n/)

index = 0
particles = particles_data.map do |particle_data|
  data = particle_data.scan(/<\s*(-*\d+)\,*(-*\d+)\,*(-*\d+)\,*>/)
  q = data.map do |vector|
    Point3.new(*vector.map(&:to_i))
  end

  particle = Particle.new(index, *q)
  index += 1
  particle
end

if ARGV[0] == "1"
  groups = {}
  50_000.times do |idx|
    particles.each(&:update)
    groups = particles.group_by &:distance
    puts "iteration: #{idx + 1}" if idx % 10_000 == 0
  end
  particle = groups.min[1].first
  puts "closest particle: #{particle.id}"

else
  groups = {}
  10_000.times do |idx|
    groups = particles.group_by &:position_string
    collisions = groups.select { |_, g| g.count > 1 }.values.flatten.map(&:id)

    particles = particles.reject { |p| collisions.include?(p.id)}


    particles.each(&:update)
    puts "iteration: #{idx + 1}" if idx % 10_000 == 0
  end
  puts "particle count: #{particles.count}"
end
