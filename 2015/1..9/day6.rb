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
      grid[x][y] -= 1 if (grid[x][y]).positive?
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
    turn_on(grid, Regexp.last_match(1).to_i, Regexp.last_match(2).to_i, Regexp.last_match(3).to_i,
            Regexp.last_match(4).to_i)
  when /turn off (\d+),(\d+) through (\d+),(\d+)/
    turn_off(grid, Regexp.last_match(1).to_i, Regexp.last_match(2).to_i, Regexp.last_match(3).to_i,
             Regexp.last_match(4).to_i)
  when /toggle (\d+),(\d+) through (\d+),(\d+)/
    toggle(grid, Regexp.last_match(1).to_i, Regexp.last_match(2).to_i, Regexp.last_match(3).to_i,
           Regexp.last_match(4).to_i)
  end
end

puts grid.flatten.inject(:+)
