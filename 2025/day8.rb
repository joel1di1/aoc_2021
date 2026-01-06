require_relative '../fwk'

class Point
  attr_accessor :x, :y, :z, :circuit

  def initialize(x, y, z)
    self.x = x
    self.y = y
    self.z = z
  end

  def to_s
    "(#{x},#{y},#{z})"
  end

  def distance(other)
    ((x-other.x)**2) + ((y-other.y)**2) + ((z-other.z)**2)
  end

  def <=>(other)
    comp = x - other.x
    return comp if comp != 0

    comp = y - other.y
    return comp if comp != 0

    z - other.z
  end
  
  def connect(point)
    circuit.merge(point.circuit)
  end
end

class Circuit
  attr_reader :points

  def initialize
    @points = Set.new
  end

  def size
    @points.size
  end

  def merge(other)
    return if other == self

    other.points.each do |point|
      self << point
    end
  end

  def <<(point)
    @points << point
    point.circuit = self
  end

  def to_s
    points.sort.join(',')
  end
end

lines = File.readlines(File.join(__dir__, 'input8.txt'), chomp: true)

points = lines.map { |line| Point.new(*line.split(',').map(&:to_i)) }

points = points.sort

points.map do |point|
  circuit = Circuit.new
  circuit.points << point
  point.circuit = circuit
  circuit
end

distances = []

points.each_with_index do |a, i|
  points[(i + 1)..].each do |b|
    next if a == b

    distances << [a.distance(b), a, b]
  end
end

distances = distances.sort_by do |dist, _a, _b|
  dist
end

# puts "start"
# puts points.map(&:circuit).uniq

(0...1000).each do |i|
  _dist, a, b = distances[i]

  a.connect(b)

  # circuits = points.map(&:circuit).uniq
  # puts "\nafter round #{i}: #{circuits.size} circuits"
  # puts points.map(&:circuit).uniq
end

circuits = points.map(&:circuit).uniq
part1 = circuits.map(&:size).sort.reverse[0...3].reduce(:*)

puts "part 1 : #{part1}"

i = 1000
last_a = nil
last_b = nil

until points.map(&:circuit).uniq.size == 1
  _dist, last_a, last_b = distances[i]
  last_a.connect(last_b)
  i += 1
end

puts "part 2 : #{last_a.x * last_b.x}"
