# frozen_string_literal: true

require_relative '../../fwk'

class Scan
  attr_reader :distances_to_points, :name, :points

  def initialize(name)
    @name = name
    @points = []
    @distances_to_points = {}
  end

  def distances
    @distances_to_points.keys
  end

  def <<(point)
    @points << point
  end

  def to_s
    "Scan #{@name}\n#{@points.map(&:to_s).join("\n")}\n\n"
  end

  def compute_distances
    @points.each_with_index do |p1, i|
      @points[i + 1..].each do |p2|
        d = Math.sqrt((p1.x - p2.x).pow(2) + (p1.y - p2.y).pow(2) + (p1.z - p2.z).pow(2))
        p1.distances[p2] = d
        p2.distances[p1] = d
        @distances_to_points[d] = [p1, p2]

        p1.vectors[p2] = Point.new(p2.x - p1.x, p2.y - p1.y, p2.z - p1.z)
        p2.vectors[p1] = Point.new(p1.x - p2.x, p1.y - p2.y, p1.z - p2.z)
      end
    end
  end
end

class Point
  attr_reader :x, :y, :z, :distances, :vectors

  def initialize(x, y, z)
    @x = x
    @y = y
    @z = z
    @distances = {}
    @vectors = {}
  end

  def to_s
    "(#{x}, #{y}, #{z})"
  end
end

def read_inputs(file)
  scans = []
  lines = File.readlines(file).map(&:strip)
  scan = nil
  index = 0
  until lines.empty?
    line = lines.shift
    case line
    when /scanner/
      scan = Scan.new index
      index += 1
      scans << scan
    when /(-?\d+),(-?\d+),(-?\d+)/
      scan << Point.new(Regexp.last_match[1].to_i, Regexp.last_match[2].to_i, Regexp.last_match[3].to_i)
    end
  end
  scans
end

def rotate(vectors, rotation)
  rx, ry, rz, sym = rotation
  vectors.map do |_vector|
    vector = _vector
    rx.times { vector = Point.new(vector.x, -vector.z, vector.y) }
    ry.times { vector = Point.new(-vector.z, vector.y, vector.x) }
    rz.times { vector = Point.new(vector.y, -vector.x, vector.z) }
    vector
  end
end

rotations = []
(0..3).each do |rx|
  (0..3).each do |ry|
    (0..3).each do |rz|
      rotations << [rx, ry, rz]
    end
  end
end

scans = read_inputs('day19.txt')
scans.each(&:compute_distances)

s1 = scans.first
match_with_s1 = scans[1..].select { |s2| (s1.distances - s2.distances).count <= 259 }
puts match_with_s1.map(&:name).join(", ")

s2 = match_with_s1.first
distances = s1.distances.intersection(s2.distances)

s1_points = s1.distances_to_points[distances.first].flatten.uniq
s2_points = s2.distances_to_points[distances.first].flatten.uniq

v1 = s1_points[0].vectors[s1_points[1]]
v2 = s2_points[0].vectors[s2_points[1]]

rotation = rotations.find do |rotation|
  puts "\ttest rotation #{rotation}"
  puts v1
  puts rotate([v2], rotation).first
  v1 == rotate([v2], rotation).first
end

puts "rotation: #{rotation} !"
puts "OK"