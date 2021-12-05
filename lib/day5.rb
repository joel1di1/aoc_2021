# frozen_string_literal: true

require 'readline'
require 'byebug'

content = File.readlines('inputs/day5.txt')

class Point
  attr_reader :x, :y

  def initialize(x, y)
    @x = x
    @y = y
  end

  def ==(other)
    x == other.x && y == other.y
  end

  def next_to(target)
    Point.new(next_value(x, target.x), next_value(y, target.y))
  end

  private

  def next_value(current, target)
    return current if current == target

    current + (target > current ? 1 : -1)
  end
end

class Line
  attr_reader :start_point, :end_point

  def initialize(x1, y1, x2, y2)
    @start_point = Point.new(x1, y1)
    @end_point = Point.new(x2, y2)
  end

  def points
    current = start_point
    points = [current]

    while current != end_point
      current = current.next_to(end_point)
      points << current
    end
    points
  end

  def draw_on(diagram)
    points.each do |point|
      diagram[point.x] = [] unless diagram[point.x]
      diagram[point.x][point.y] = (diagram[point.x][point.y] || 0) + 1
    end
  end
end

max_x = 0
max_y = 0

lines = content.map do |line|
  a = line.split(' ')
  x1, y1 = a.first.split(',').map(&:to_i)
  x2, y2 = a.last.split(',').map(&:to_i)
  max_x = [max_x, x1, x2].max
  max_y = [max_y, y1, y2].max
  Line.new(x1, y1, x2, y2)
end

diagram = Array.new(max_x) { Array.new(max_y, 0) }

lines.each { |line| line.draw_on(diagram) }

pp diagram.flatten.compact.select { |i| i >= 2 }.count
