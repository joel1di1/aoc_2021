# frozen_string_literal: true

require 'set'

# Read input from file
input = File.read('day8.txt').strip.split("\n").map(&:chars)

# Get dimensions of grid
height = input.length
width = input[0].length

# Calculate scenic score for a tree
def scenic_score(grid, x, y)
  height = grid[y][x]
  score = 1
  if x > 0 # check left
    i = x - 1
    while i >= 0 && grid[y][i] < height
      i -= 1
    end
    score *= (x - i)
  else 
    score = 0
  end
  if x < grid[0].length - 1 # check right
    i = x + 1
    while i < grid[0].length && grid[y][i] < height
      i += 1
    end
    score *= (i - x)
  else
    score = 0
  end
  if y > 0 # check up
    i = y - 1
    while i >= 0 && grid[i][x] < height
      i -= 1
    end
    score *= (y - i)
  else
    score = 0
  end
  if y < grid.length - 1 # check down
    i = y + 1
    while i < grid.length && grid[i][x] < height
      i += 1
    end
    score *= (i - y)
  else
    score = 0
  end
  score
end

# Find highest scenic score
highest_score = 0
height.times do |y|
  width.times do |x|
    score = scenic_score(input, x, y)
    highest_score = score if score > highest_score
  end
end

# Print highest scenic score
puts highest_score
