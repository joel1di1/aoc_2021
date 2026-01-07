require_relative '../fwk'

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
    inside = false
    inside_wall_x = nil

    while i < seg_same_x_to_check.size
      current_seg = seg_same_x_to_check[i]
      debug "\t\t current_seg: #{current_seg}"
      # segment is to the left of the rectangle
      
      if current_seg.a.x < top_left_corner.x
        # segment is at the left of the rectangle
        inside = !inside
        debug "\t\t wall on the left, inside=#{inside}"
      elsif top_left_corner.x <= current_seg.a.x && current_seg.b.x <= bottom_right_corner.x
        # segment is inside the rectangle
        if inside
          # we are inside the rectangle
          if inside_wall_x.nil?
            debug "\t\t wall inside, inside=#{inside} => set inside_wall_x to #{current_seg.a.x}"
            inside_wall_x = current_seg.a.x
          elsif inside_wall_x + 1 == current_seg.a.x || seg_same_y.include?(Segment.new(Point.new(inside_wall_x, y), Point.new(current_seg.a.x, y)))
            # we had seen a wall, need to check if a segment is connecting the two walls
            # of if the 2 walls are touching
            debug "\t\t wall inside, inside=#{inside} => ok"
            inside_wall_x = nil
          else
            debug "\t\t wall inside, inside=#{inside}, inside_wall_x=#{inside_wall_x} => nok"
            return false
          end
        elsif current_seg.a.x > top_left_corner.x
          # we are outside the rectangle
          debug "\t\t wall inside, inside=#{inside} => nok"
          return false
        else
          debug "\t\t wall inside, inside=#{inside} => set inside_wall_x to #{current_seg.a.x}"
          inside_wall_x = current_seg.a.x
        end
      
      elsif current_seg.a.x > bottom_right_corner.x
        # segment is on the right of the rectangle
        if inside
          if inside_wall_x.nil?
            debug "\t\t wall on the right, inside=#{inside}, inside_wall_x=nil => ok"
            break 
          else
            debug "\t\t wall on the right, inside=#{inside}, inside_wall_x=#{inside_wall_x}"
            return false unless seg_same_y.include?(Segment.new(Point.new(inside_wall_x, y), Point.new(current_seg.a.x, y)))

            debug "\t\t wall on the right, inside=#{inside} => ok"
            break
          end
        else
          debug "\t\t wall on the right, inside=#{inside} => nok"
          return false
        end
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
  puts "checking rec: #{rectangle}, \tarea: #{rectangle.area} \t #{i}/#{total_rec} \t #{i/total_rec}" if i % 1000 == 0
  i += 1
  valid?(rectangle, seg_same_x, seg_same_y)
end

puts "part 2 : #{largest.area}"


