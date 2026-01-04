require_relative '../../fwk'

class Point
  attr_accessor :x, :y

  def initialize(x, y)
    self.x = x
    self.y = y
  end

  def to_s
    "(#{x},#{y})"
  end

  def area_with(other)
    ((x - other.x) + 1).abs * ((y - other.y)+1).abs
  end

  def <=>(other)
    comp = x - other.x
    return comp if comp != 0

    comp = y - other.y
  end  
end

lines = File.readlines(File.join(__dir__, 'input9.txt'), chomp: true)

points = lines.map { |line| Point.new(*line.split(',').map(&:to_i)) }
points = points.sort

max_area = points.map do |a|
  points.map do |b|
    a.area_with(b)
  end
end.flatten.max

puts "part 1 : #{max_area}"
puts "part 2 : #{}"
