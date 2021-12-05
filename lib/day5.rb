require 'readline'
require 'byebug'

content = File.readlines('inputs/day5.txt')

class Point
  attr_reader :x, :y

  def initialize(x,y)
    @x = x
    @y = y
  end
end

class Line
  attr_reader :x1, :y1, :x2, :y2

  def initialize(x1, y1, x2, y2)
    @x1 = x1
    @y1 = y1
    @x2 = x2
    @y2 = y2
  end

  def points
    return [] if x1 != x2 && y1 != y2

    if x1 != x2
      xs = [x1, x2]
      (xs.min..xs.max).map { |x| Point.new(x,y1) }
    else
      ys = [y1, y2]
      (ys.min..ys.max).map { |y| Point.new(x1,y) }
    end
  end

  def draw_on(diagram)
    points.each do |point|
      diagram[point.x] = [] unless diagram[point.x]
      diagram[point.x][point.y] = (diagram[point.x][point.y] || 0) + 1
    end
  end
end

max_x, max_y = 0, 0

lines = content.map do |line|
  a  = line.split(' ');
  x1, y1 = a.first.split(',').map(&:to_i)
  x2, y2 = a.last.split(',').map(&:to_i)
  max_x = [max_x, x1, x2].max
  max_y = [max_y, y1, y2].max
  Line.new(x1, y1, x2, y2)
end

diagram = Array.new(max_x) { Array.new(max_y, 0) }

lines.each { |line| line.draw_on(diagram) }

pp diagram.flatten.compact.select{|i| i >= 2}.count

