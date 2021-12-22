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
    "Scan #{@name}" # \n#{@points.map(&:to_s).join("\n")}\n\n"
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

  def rotate!(rotation)
    @points.each { |p| p.rotate!(rotation) }
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

  def ==(other)
    x == other.x && y == other.y && z == other.z
  end

  def rotate!(rotation)
    rx, ry, rz = rotation
    rx.times do
      tmp = @y
      @y = @z
      @z = -tmp
    end
    ry.times do
      tmp = @x
      @x = -@z
      @z = tmp
    end
    rz.times do
      tmp = @x
      @x = @y
      @y = -tmp
    end

    vectors.values.map { |v| v.rotate!(rotation) }
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

def rotate(vector, rotation)
  rx, ry, rz = rotation
  rx.times { vector = Point.new(vector.x, vector.z, -vector.y) }
  ry.times { vector = Point.new(-vector.z, vector.y, vector.x) }
  rz.times { vector = Point.new(vector.y, -vector.x, vector.z) }
  vector
end

def rotations
  @rotations ||= begin
    tmp_rotations = []
    (0..3).each do |rx|
      (0..3).each do |ry|
        (0..3).each do |rz|
          tmp_rotations << [rx, ry, rz]
        end
      end
    end

    v = Point.new(1, 2, 3)
    h = {}
    tmp_rotations.map { |rot| h[rotate(v, rot).to_s] ||= rot }
    h.values
  end
end

def get_matching_vectors(distances_in_common, s1, scan_match)
  distances_in_common[0, 2].map do |distance_in_common|
    s1_points = s1.distances_to_points[distance_in_common].flatten.uniq
    scan_match_points = scan_match.distances_to_points[distance_in_common].flatten.uniq

    [s1_points[0].vectors[s1_points[1]], scan_match_points[0].vectors[scan_match_points[1]]]
  end
end

puts "count: #{rotations.count}"
puts "count uniq: #{rotations.uniq.count}"

scans = read_inputs('day19.txt')
scans.each(&:compute_distances)

s1 = scans.first
scan_match_with_s1 = scans[1..].select { |s2| (s1.distances - s2.distances).count <= 259 }
puts "#{scan_match_with_s1.map(&:name).join(',')} has 12 points in commmon with #{s1}"

scan_match_with_s1.each do |scan_match|
  puts "trying #{scan_match}"
  distances_in_common = s1.distances.intersection(scan_match.distances)

  matching_vectors_list = get_matching_vectors(distances_in_common, s1, scan_match)
  rotation = rotations.find do |rotation|
    matching_vectors_list.all? do |matching_vectors|
      matching_vectors[0] == rotate(matching_vectors[1], rotation)
    end
  end

  scan_match.rotate!(rotation)
end

puts "rotation: #{rotation} !"
puts "OK"
