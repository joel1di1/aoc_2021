require 'timeout'
require 'set'

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
    ((x - other.x).abs + 1) * ((y - other.y).abs + 1)
  end
end

class Rectangle
  attr_accessor :a, :b

  def initialize(a, b)
    self.a = a
    self.b = b
  end

  def area
    (1 + (b.x - a.x).abs) * (1 + (b.y - a.y).abs)
  end

  def to_s
    "[#{a}, #{b}]"
  end
end

class Segment
  attr_accessor :a, :b

  def initialize(a, b)
    # Normalize: a should have smaller coordinates
    if a.x > b.x || (a.x == b.x && a.y > b.y)
      self.a = b
      self.b = a
    else
      self.a = a
      self.b = b
    end
  end

  def to_s
    "<#{a} -> #{b}>"
  end
end

def parse_input(filename)
  lines = File.readlines(File.join(__dir__, filename), chomp: true)
  lines.map { |line| Point.new(*line.split(',').map(&:to_i)) }
end

def build_segments(points)
  segments = (1...points.size).map do |i|
    Segment.new(points[i-1], points[i])
  end
  segments << Segment.new(points[-1], points[0])

  # Separate vertical and horizontal segments
  vertical = segments.select { |seg| seg.a.x == seg.b.x }
  horizontal = segments.select { |seg| seg.a.y == seg.b.y }

  [vertical, horizontal]
end

def valid?(rectangle, vertical_segments)
  left_x = [rectangle.a.x, rectangle.b.x].min
  right_x = [rectangle.a.x, rectangle.b.x].max
  top_y = [rectangle.a.y, rectangle.b.y].min
  bottom_y = [rectangle.a.y, rectangle.b.y].max

  # Optimization: Only check y values where segments start/end (where crossing pattern changes)
  # Plus the rectangle boundaries
  critical_y_values = Set.new([top_y, bottom_y])
  vertical_segments.each do |seg|
    critical_y_values << seg.a.y if seg.a.y >= top_y && seg.a.y <= bottom_y
    critical_y_values << seg.b.y if seg.b.y >= top_y && seg.b.y <= bottom_y
  end

  # Check critical scanlines
  critical_y_values.all? do |y|
    # Select vertical segments that cross this scanline
    # Use < for top endpoint to avoid double-counting at corners
    crossing_segments = vertical_segments.select do |seg|
      seg.a.y <= y && y < seg.b.y
    end

    # Also check for segments that END at this y (for boundary detection)
    ending_segments = vertical_segments.select do |seg|
      seg.b.y == y
    end

    # Check left edge: must be inside or on boundary
    crossings_left = crossing_segments.count { |seg| seg.a.x < left_x }
    on_left_boundary = crossing_segments.any? { |seg| seg.a.x == left_x } ||
                      ending_segments.any? { |seg| seg.a.x == left_x }
    return false if crossings_left.even? && !on_left_boundary

    # Check right edge: must be inside or on boundary
    crossings_right = crossing_segments.count { |seg| seg.a.x < right_x }
    on_right_boundary = crossing_segments.any? { |seg| seg.a.x == right_x } ||
                       ending_segments.any? { |seg| seg.a.x == right_x }
    return false if crossings_right.even? && !on_right_boundary

    true
  end
end

def solve_part1(points)
  max_area = 0
  points.each_with_index do |a, i|
    ((i+1)...points.size).each do |j|
      b = points[j]
      area = a.area_with(b)
      max_area = area if area > max_area
    end
  end
  max_area
end

def solve_part2(points, vertical_segments, timeout_seconds = 60)
  # Generate all rectangles
  rectangles = []
  points.each_with_index do |a, i|
    ((i+1)...points.size).each do |j|
      b = points[j]
      rectangles << Rectangle.new(a, b)
    end
  end

  # Sort by area descending (check largest first)
  rectangles.sort_by!(&:area)
  rectangles.reverse!

  puts "Checking #{rectangles.size} rectangles..."

  # Find largest valid rectangle with timeout protection
  start_time = Time.now
  checked = 0

  rectangles.each do |rectangle|
    # Check timeout
    if Time.now - start_time > timeout_seconds
      puts "Timeout after #{checked} rectangles checked!"
      return nil
    end

    checked += 1
    if checked % 1000 == 0
      elapsed = Time.now - start_time
      puts "Checked #{checked}/#{rectangles.size} rectangles (#{elapsed.round(1)}s elapsed, current area: #{rectangle.area})"
    end

    if valid?(rectangle, vertical_segments)
      puts "Found valid rectangle #{rectangle} with area #{rectangle.area} after checking #{checked} rectangles!"
      return rectangle.area
    end
  end

  puts "No valid rectangle found after checking all #{checked} rectangles"
  nil
end

# Main execution
if __FILE__ == $0
  # Test with example
  puts "=== Example Input ==="
  points = parse_input('input9_test.txt')
  puts "Points: #{points.size}"

  part1 = solve_part1(points)
  puts "Part 1: #{part1}"

  vertical_segments, horizontal_segments = build_segments(points)
  puts "Vertical segments: #{vertical_segments.size}"
  puts "Horizontal segments: #{horizontal_segments.size}"

  part2 = solve_part2(points, vertical_segments, 60)
  puts "Part 2: #{part2}"

  puts "\n=== Real Input ==="
  points = parse_input('input9.txt')
  puts "Points: #{points.size}"

  part1 = solve_part1(points)
  puts "Part 1: #{part1}"

  vertical_segments, horizontal_segments = build_segments(points)
  puts "Vertical segments: #{vertical_segments.size}"
  puts "Horizontal segments: #{horizontal_segments.size}"

  part2 = solve_part2(points, vertical_segments, 60)
  puts "Part 2: #{part2}"
end
