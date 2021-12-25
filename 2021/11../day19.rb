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

  def to_str
    "Scan #{@name}" # \n#{@points.map(&:to_s).join("\n")}\n\n"
  end

  alias_method :to_s, :to_str

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

  def translate!(translation)
    @points.each { |p| p.translate!(translation) }
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

  def to_str
    "(#{x}, #{y}, #{z})"
  end

  alias_method :to_s, :to_str

  def ==(other)
    x == other.x && y == other.y && z == other.z
  end

  def <=>(other)
    x <=> other.x || y <=> other.y || z <=> other.z
  end

  def translate!(translation)
    tx, ty, tz = translation
    @x += tx
    @y += ty
    @z += tz
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

  def length
    Math.sqrt(x.pow(2) + y.pow(2) + z.pow(2))
  end

  def coords
    [x, y, z]
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

def get_matching_points_and_vectors(distances_in_common, s1, scan_match)

  s2_vectors = nil
  s1_first_point = nil
  s1_first_vector = nil
  s1_second_vector = nil
  s2_first_point = nil

  distances_in_common.find do |first_distance|
    s1_first_point, s1_second_point = s1.distances_to_points[first_distance]
    s1_first_vector = s1_first_point.vectors[s1_second_point]

    s1_second_vector = s1_first_point.vectors.values.find do |vector|
      vector != s1_first_vector && distances_in_common.include?(vector.length)
    end

    s2_points = scan_match.distances_to_points[first_distance]
    s2_first_point = s2_points.find do |p|
      p.vectors.values.select do |v|
        [s1_first_vector, s1_second_vector].map(&:length).include?(v.length)
      end
    end

    s2_vectors = s2_first_point.vectors.values.select do |v|
      [s1_first_vector, s1_second_vector].map(&:length).include?(v.length)
    end

    s2_vectors && s2_vectors.length >= 2
  end

  [s1_first_point, [s1_first_vector, s1_second_vector].sort_by(&:length), s2_first_point, s2_vectors.sort_by(&:length)]
end

puts "count: #{rotations.count}"
puts "count uniq: #{rotations.uniq.count}"

unprocessed_scans = read_inputs('day19.txt')
unprocessed_scans.each(&:compute_distances)

scans_to_do = [unprocessed_scans.shift]
scans_done = []
until unprocessed_scans.empty?
  s1 = scans_to_do.shift
  scan_match_with_s1 = unprocessed_scans.select { |s2| (s1.distances - s2.distances).count <= 259 }
  puts "#{scan_match_with_s1.map(&:name).join(',')} has 12 points in commmon with #{s1}"

  scan_match_with_s1.each do |scan_match|
    puts "trying #{scan_match}"
    distances_in_common = s1.distances.intersection(scan_match.distances)

    s1_point, s1_vectors, s2_point, s2_vectors = get_matching_points_and_vectors(distances_in_common, s1, scan_match)
    rotation = rotations.find do |rotation|
      (0..1).all? do |i|
        s1_vectors[i] == rotate(s2_vectors[i], rotation)
      end
    end

    scan_match.rotate!(rotation)

    translation = [-(s2_point.x - s1_point.x), -(s2_point.y - s1_point.y), -(s2_point.z - s1_point.z)]
    scan_match.translate!(translation)

    puts "#{scan_match.to_s} should match #{s1}. Rotation: #{rotation}, translation: #{translation}"
  end

  scan_match_with_s1.each do |scan|
    unprocessed_scans.delete(scan)
    scans_to_do << scan
  end
  scans_done << s1
end

scans_done = scans_done.concat(scans_to_do)

all_points_coords = scans_done.flatten.map(&:points).flatten.sort.map(&:coords)
puts "all_points: #{all_points_coords}"
puts "all_points count: #{all_points_coords.count}"
puts "all_points uniq count: #{all_points_coords.uniq.count}"
