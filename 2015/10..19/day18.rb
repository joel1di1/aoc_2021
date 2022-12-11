require 'byebug'

original_grid = File.readlines('day18.txt').map(&:strip).map { |line| line.chars.map{|c| c =='#' ? 1 : 0} }
SIZE = original_grid.size

MASK = [[-1, -1], [-1, +0], [-1, 1],
        [+0, -1],           [+0, 1],
        [+1, -1], [+1, +0], [+1, 1]].freeze

def step(grid, broken = false)
  new_grid = Array.new(SIZE) {Array.new(SIZE) { 0 }}

  (0..SIZE-1).each do |i|
    (0..SIZE-1).each do |j|
      neighbors_on = MASK.map { |x, y| [i + x, j + y] }.select { |x,y|  x >= 0 && x < SIZE && y >= 0 && y < SIZE }.map{ |x,y| grid[x][y] }
      debugger if neighbors_on.any?(&:nil?)
      neighbors_on = neighbors_on.sum

      if grid[i][j] == 1
        new_grid[i][j] = 1 if neighbors_on == 2 || neighbors_on == 3
      else
        new_grid[i][j] = 1 if neighbors_on == 3
      end
    end
  end
  if broken
    new_grid[0][0] = 1
    new_grid[0][-1] = 1
    new_grid[-1][0] = 1
    new_grid[-1][-1] = 1
  end
  new_grid
end

grid_part1 = original_grid

100.times do |step|
  grid_part1 = step(grid_part1)
end

puts "part1 : #{grid_part1.flatten.sum}"


grid_part2 = original_grid
grid_part2[0][0] = 1
grid_part2[0][-1] = 1
grid_part2[-1][0] = 1
grid_part2[-1][-1] = 1

100.times do |step|
  grid_part2 = step(grid_part2, true)
end

puts "part2 : #{grid_part2.flatten.sum}"
