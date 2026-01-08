# frozen_string_literal: true

require_relative '../fwk'

Point = Struct.new(:x, :y, keyword_init: true)

input_name = ARGV[0] || 'input9.txt'
input_path = if File.exist?(input_name)
               input_name
             else
               File.join(__dir__, input_name)
             end
lines = File.readlines(input_path, chomp: true)
points = lines.map do |line|
  x, y = line.split(',').map(&:to_i)
  Point.new(x: x, y: y)
end

n = points.size

segments = []
(0...n).each do |i|
  a = points[i]
  b = points[(i + 1) % n]
  segments << [a.x, a.y, b.x, b.y]
end

verticals = []
horizontals = []
segments.each do |x1, y1, x2, y2|
  if x1 == x2
    y_min, y_max = y1 < y2 ? [y1, y2] : [y2, y1]
    verticals << [x1, y_min, y_max]
  else
    x_min, x_max = x1 < x2 ? [x1, x2] : [x2, x1]
    horizontals << [y1, x_min, x_max]
  end
end

def on_boundary?(x, y, verticals, horizontals, eps)
  verticals.any? do |vx, y1, y2|
    (x - vx).abs < eps && y >= y1 - eps && y <= y2 + eps
  end || horizontals.any? do |hy, x1, x2|
    (y - hy).abs < eps && x >= x1 - eps && x <= x2 + eps
  end
end

def point_inside?(x, y, verticals, horizontals, eps: 1e-9)
  return true if on_boundary?(x, y, verticals, horizontals, eps)

  crossings = 0
  verticals.each do |vx, y1, y2|
    next unless y >= y1 && y < y2

    crossings += 1 if vx > x
  end
  crossings.odd?
end

def boundary_crosses_rectangle?(minx, maxx, miny, maxy, verticals, horizontals)
  verticals.each do |vx, y1, y2|
    next unless vx > minx && vx < maxx
    next if y2 <= miny || y1 >= maxy

    return true
  end

  horizontals.each do |hy, x1, x2|
    next unless hy > miny && hy < maxy
    next if x2 <= minx || x1 >= maxx

    return true
  end

  false
end

def line_inside?(x1, y1, x2, y2, verticals, horizontals)
  return point_inside?(x1, y1, verticals, horizontals) if x1 == x2 && y1 == y2

  if x1 == x2
    miny, maxy = y1 < y2 ? [y1, y2] : [y2, y1]
    return false unless point_inside?(x1, miny, verticals, horizontals)
    return false unless point_inside?(x1, maxy, verticals, horizontals)

    midy = (miny + maxy) / 2.0
    return false unless point_inside?(x1, midy, verticals, horizontals)

    horizontals.each do |hy, hx1, hx2|
      next unless hy > miny && hy < maxy
      next unless x1 >= hx1 && x1 <= hx2

      return false
    end
    return true
  end

  minx, maxx = x1 < x2 ? [x1, x2] : [x2, x1]
  return false unless point_inside?(minx, y1, verticals, horizontals)
  return false unless point_inside?(maxx, y1, verticals, horizontals)

  midx = (minx + maxx) / 2.0
  return false unless point_inside?(midx, y1, verticals, horizontals)

  verticals.each do |vx, vy1, vy2|
    next unless vx > minx && vx < maxx
    next unless y1 >= vy1 && y1 <= vy2

    return false
  end
  true
end

def rectangle_inside?(minx, maxx, miny, maxy, verticals, horizontals)
  return line_inside?(minx, miny, maxx, maxy, verticals, horizontals) if minx == maxx || miny == maxy

  corners = [
    [minx, miny],
    [minx, maxy],
    [maxx, miny],
    [maxx, maxy]
  ]
  corners.each do |x, y|
    return false unless point_inside?(x, y, verticals, horizontals)
  end

  midx = (minx + maxx) / 2.0
  midy = (miny + maxy) / 2.0
  return false unless point_inside?(midx, midy, verticals, horizontals)
  return false if boundary_crosses_rectangle?(minx, maxx, miny, maxy, verticals, horizontals)

  true
end

max_area = 0
(0...n).each do |i|
  xi = points[i].x
  yi = points[i].y
  (i + 1...n).each do |j|
    dx = (xi - points[j].x).abs + 1
    dy = (yi - points[j].y).abs + 1
    area = dx * dy
    max_area = area if area > max_area
  end
end

puts "part 1 : #{max_area}"

best = 0
iter = 0
founded_after = 0
(0...n).each do |i|
  xi = points[i].x
  yi = points[i].y
  (i + 1...n).each do |j|
    xj = points[j].x
    yj = points[j].y
    dx = (xi - xj).abs + 1
    dy = (yi - yj).abs + 1
    area = dx * dy
    next if area <= best

    minx, maxx = xi < xj ? [xi, xj] : [xj, xi]
    miny, maxy = yi < yj ? [yi, yj] : [yj, yi]

    iter += 1
    if rectangle_inside?(minx, maxx, miny, maxy, verticals, horizontals)
      best = area
      founded_after = iter
    end
  end
end

puts "part 2 : #{best}, after #{founded_after} iterations"
