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
    "[#{a}, #{b}] area=#{area}"
  end

  def inspect
    to_s
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

  def hash
    [a.x, a.y, b.x, b.y].hash
  end

  def eql?(other)
    a.x == other.a.x && a.y == other.a.y && b.x == other.b.x && b.y == other.b.y
  end

  def go_north_from?(x, y)
    b.x == x && a.y < y
  end

  def go_south_from?(x, y)
    a.x == x && b.y > y
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

DEBUG = true
def debug(s)
  puts s if DEBUG
end

def valid?(rectangle, seg_same_x, seg_same_y)
  seg_same_y = Set.new(seg_same_y)
  top_left_corner = Point.new([rectangle.a.x, rectangle.b.x].min, [rectangle.a.y, rectangle.b.y].min)
  bottom_right_corner = Point.new([rectangle.a.x, rectangle.b.x].max, [rectangle.a.y, rectangle.b.y].max)

  (top_left_corner.y..bottom_right_corner.y).all? do |y|
    # debug "\tchecking y=#{y} seg to check : #{Segment.new(Point.new(top_left_corner.x, y), Point.new(bottom_right_corner.x, y))}"
    seg_same_x_to_check = seg_same_x.select do |seg| 
      ([seg.a.y, seg.b.y].min..[seg.a.y, seg.b.y].max).include?(y)
    end.sort_by(&:a)

    # debug "\tseg_same_x_to_check: #{seg_same_x_to_check}"

    i = 0
    inside = false
    went_out_x = nil

    while i < seg_same_x_to_check.size
      current_seg = seg_same_x_to_check[i]
      # debug "\t\t current_seg: #{current_seg}"
      # segment is to the left of the rectangle
      
      if current_seg.a.x < top_left_corner.x
        # segment is at the left of the rectangle
        inside = !inside
        # debug "\t\t wall on the left, inside=#{inside}"
      elsif current_seg.a.x == top_left_corner.x && !inside
        inside = true
        # debug "\t\t found left wall mark as outside, => inside"
      elsif current_seg.a.x == top_left_corner.x && inside
        inside = false
        went_out_x = current_seg.a.x
        # debug "\t\t found left wall mark as inside, went_out_x=#{went_out_x}"
      elsif current_seg.a.x < bottom_right_corner.x && inside 
        if y == top_left_corner.y
          if current_seg.go_north_from?(current_seg.a.x, y)
            # debug "\t\t top left corner going up => keep inside"
          else
            # debug "\t\t top left corner going down => outside"
            inside = false
            went_out_x = current_seg.a.x
          end
        elsif y == bottom_right_corner.y
          if current_seg.go_south_from?(current_seg.a.x, y)
            # debug "\t\t bottom right corner going down => keep inside"
          else
            # debug "\t\t bottom right corner going up => outside"  
            inside = false
            went_out_x = current_seg.a.x
          end
        else
          inside = false
          went_out_x = current_seg.a.x
          # debug "\t\t inside and going out, went_out_x=#{went_out_x}"
        end
      elsif current_seg.a.x <= bottom_right_corner.x && !inside 
        # debug "\t\t outside and going in"
        if went_out_x.nil?
          # debug "\t\t went_out_x is nil  => invalid"
          return false 
        end
        unless seg_same_y.include?(Segment.new(Point.new(went_out_x, y), Point.new(current_seg.a.x, y))) || went_out_x + 1 == current_seg.a.x
          # debug "\t\t no seg between went_out_x=#{went_out_x} and current_seg #{current_seg.a.x} => invalid"
          return false 
        end

        # debug "\t\t found right wall mark as outside => inside"
        inside = true
        went_out_x = nil
      elsif bottom_right_corner.x < current_seg.a.x && !inside 
        # debug "\t\t outside and going in"
        return false if went_out_x.nil?
        return false unless seg_same_y.include?(Segment.new(Point.new(went_out_x, y), Point.new(current_seg.a.x, y))) || went_out_x + 1 == current_seg.a.x

      elsif bottom_right_corner.x <= current_seg.a.x && inside 
        # debug "\t\t inside and going out, done for this y"
        break
      else
        debugger
        raise "unhandled case #{current_seg} for rectangle #{rectangle}"
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


