# frozen_string_literal: true

grid = Array.new(1000) { Array.new(1000, 0) }

def turn_on(grid, x1, y1, x2, y2)
  (x1..x2).each do |x|
    (y1..y2).each do |y|
      grid[x][y] += 1
    end
  end
end

def turn_off(grid, x1, y1, x2, y2)
  (x1..x2).each do |x|
    (y1..y2).each do |y|
      grid[x][y] -= 1 if grid[x][y] > 0
    end
  end
end

def toggle(grid, x1, y1, x2, y2)
  (x1..x2).each do |x|
    (y1..y2).each do |y|
      grid[x][y] += 2
    end
  end
end

File.readlines('day6.txt').each do |line|
  case line
  when /turn on (\d+),(\d+) through (\d+),(\d+)/
    turn_on(grid, $1.to_i, $2.to_i, $3.to_i, $4.to_i)
  when /turn off (\d+),(\d+) through (\d+),(\d+)/
    turn_off(grid, $1.to_i, $2.to_i, $3.to_i, $4.to_i)
  when /toggle (\d+),(\d+) through (\d+),(\d+)/
    toggle(grid, $1.to_i, $2.to_i, $3.to_i, $4.to_i)
  end
end

puts grid.flatten.inject(:+)