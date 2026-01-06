require_relative '../fwk'

def parse_grid(path)
  rows = File.readlines(path, chomp: true)
  height = rows.size
  width = rows.first.size

  grid = {}
  rows.each_with_index do |row, x|
    row.chars.each_with_index do |char, y|
      grid[[x, y]] = char
    end
  end

  [grid, width, height]
end 

def neighbors(x, y, width, height)
  [
    [x - 1, y - 1], [x, y - 1], [x + 1, y - 1],
    [x - 1, y],                 [x + 1, y],
    [x - 1, y + 1], [x, y + 1], [x + 1, y + 1]
  ].select { |a, b| a.between?(0, width - 1) && b.between?(0, height - 1) }
end

def liftable?(grid, width, height, x, y)
  return false unless grid[[x, y]] == '@'

  neighbors(x, y, width, height).count { |neighbor| grid[neighbor] == '@' } < 4
end

def count_liftable(grid, width, height)
  (0...width).sum do |x|
    (0...height).count { |y| liftable?(grid, width, height, x, y) }
  end
end

def lift_until_stable(grid, width, height)
  remaining = grid.dup

  loop do
    liftable_positions = []

    (0...width).each do |x|
      (0...height).each do |y|
        liftable_positions << [x, y] if liftable?(remaining, width, height, x, y)
      end
    end

    break if liftable_positions.empty?

    liftable_positions.each { |pos| remaining.delete(pos) }
  end

  remaining
end

grid, width, height = parse_grid(File.join(__dir__, 'input4.txt'))

part1 = count_liftable(grid, width, height)
remaining_grid = lift_until_stable(grid, width, height)

initial_roll_count = grid.values.count('@')
final_roll_count = remaining_grid.values.count('@')

puts "part 1 : #{part1}"
puts "part 2 : #{initial_roll_count - final_roll_count}"
