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

    y - other.y
  end  
end

class Rectangle
  attr_accessor :a, :b

  def initialize(a, b)
    self.a = a
    self.b = b
  end

  def cover?(x, y)
    (b.x..a.x).include?(x) && 
      (b.y..a.y).include?(y)
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
    if a.x > b.x || a.y > b.y
      self.a = b
      self.b = a
      return 
    end

    self.a = a
    self.b = b
  end

  def inspect
    "<#{a} -> #{b}>"
  end

  def to_s
    inspect
  end

  def <=>(other)
    comp = a <=> other.a
    return comp if comp != 0

    b <=> other.b
  end
end

lines = File.readlines(File.join(__dir__, 'input9.txt'), chomp: true)

POINTS = lines.map { |line| Point.new(*line.split(',').map(&:to_i)) }.freeze
sorted_points = POINTS.sort

segments = 
  (1...POINTS.size).map do |i|
    Segment.new(POINTS[i-1], POINTS[i])
  end

segments << Segment.new(POINTS[0], POINTS[-1])
seg_same_x = []
seg_same_y = []
segments.each do |seg|
  if seg.a.x == seg.b.x
    seg_same_x << seg
  else
    seg_same_y << seg
  end
end

seg_same_x.sort_by!(&:a)

max_area = sorted_points.map do |a|
  sorted_points.map do |b|
    a.area_with(b)
  end
end.flatten.max

puts "part 1 : #{max_area}"

DEBUG = false
def debug(s)
  puts s if DEBUG
end

def valid?(rectangle, seg_same_x, seg_same_y)
  seg_same_y = Set.new(seg_same_y)
  top_left_corner = Point.new([rectangle.a.x, rectangle.b.x].min, [rectangle.a.y, rectangle.b.y].min)
  bottom_right_corner = Point.new([rectangle.a.x, rectangle.b.x].max, [rectangle.a.y, rectangle.b.y].max)

  (top_left_corner.y..bottom_right_corner.y).all? do |y|
    debug "\tchecking y=#{y} seg to check : #{Segment.new(Point.new(top_left_corner.x, y), Point.new(bottom_right_corner.x, y))}"
    seg_same_x_to_check = seg_same_x.select do |seg| 
      ([seg.a.y, seg.b.y].min..[seg.a.y, seg.b.y].max).include?(y)
    end.sort_by(&:a)

    debug "\tseg_same_x_to_check: #{seg_same_x_to_check}"

    i = 0
    lefts = 0
    inside_wall_x = nil
    while i < seg_same_x_to_check.size
      current_seg = seg_same_x_to_check[i]
      debug "\t\t current_seg: #{current_seg}"
      # debugger
      if current_seg.a.x < top_left_corner.x
        lefts += 1
        debug "\t\t add to lefts: #{lefts}"
      elsif current_seg.a.x == top_left_corner.x && lefts.odd?
        debug "\t\t encountering the wall, but with left: #{lefts}"
        return false
      elsif current_seg.a.x == top_left_corner.x
        lefts += 1
        debug "\t\t encountering the wall, correct"
      elsif current_seg.a.x < bottom_right_corner.x && !(y == current_seg.b.y || y == current_seg.a.y)
        debug "\t\t encountering wall inside rectangle current_seg.a.x=#{current_seg.a.x}, inside_wall_x=#{inside_wall_x}"
        if inside_wall_x.nil?
          inside_wall_x = current_seg.a.x
        else
          return false unless seg_same_y.include?(Segment.new(Point.new(inside_wall_x, y), Point.new(current_seg.a.x, y)))
            
          inside_wall_x = nil
        end
      elsif lefts.even?
        debug "\t\t find end wall, but no start"
        return false
      else
        break
      end
      i += 1
    end
    true
  end
end

rectangles = sorted_points.map.with_index do |a, i|
  ((i+1)...sorted_points.size).map do |j|
    b = sorted_points[j]
    Rectangle.new(a, b)
  end
end.flatten

rectangles_by_area = rectangles.sort_by(&:area).reverse

puts segments.size
puts "segments: #{segments}"
puts seg_same_x

total_rec = rectangles_by_area.count
i = 0

largest = rectangles_by_area.find do |rectangle|
  puts "checking rec: #{rectangle}, \tarea: #{rectangle.area} \t #{i}/#{total_rec} \t #{i/total_rec}"
  i += 1
  valid?(rectangle, seg_same_x, seg_same_y)
end

puts "part 2 : #{largest.area}"


