# frozen_string_literal: true

require 'set'

# Read input from file
input = File.read('day8.txt').strip.split("\n").map(&:chars)

# Get dimensions of grid
height = input.length
width = input[0].length

# Check if a tree is visible from a certain direction
def visible?(grid, x, y, dx, dy)
  cx, cy = x + dx, y + dy
  while cx >= 0 && cy >= 0 && cx < grid[0].length && cy < grid.length
    return false if grid[cy][cx] >= grid[y][x]
    cx += dx
    cy += dy
  end
  true
end

# Find visible trees
visible_trees = Set.new
height.times do |y|
  width.times do |x|
    visible_trees.add([x, y]) if visible?(input, x, y, 1, 0) ||
                                  visible?(input, x, y, -1, 0) ||
                                  visible?(input, x, y, 0, 1) ||
                                  visible?(input, x, y, 0, -1)
  end
end

# Count visible trees
puts visible_trees.length
