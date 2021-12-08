# frozen_string_literal: true

require 'byebug'
require 'readline'
require 'set'

def different?(previous_grid, grid)
  previous_grid.flatten != grid.flatten
end

def neighbours_coords(i, j, i_max, j_max)
  [[i - 1, j - 1], [i - 1, j], [i -1, j + 1],
   [i, j - 1], [i, j + 1],
   [i + 1, j - 1], [i + 1, j], [i + 1, j + 1]].select do |i, j|
    i >= 0 && j >= 0 && i < i_max && j < j_max
  end
end

def neighbours(i, j, grid)
  neighbours_coords(i, j, grid.size, grid.first.size).map { |i, j| grid[i][j] }
end

def change(grid)
  grid.map.with_index do |row, i|
    row.map.with_index do |seat, j|
      case seat
      when 'L'
        neighbours(i, j, grid).count('#').zero? ? '#' : 'L'
      when '#'
        neighbours(i, j, grid).count('#') >= 4 ? 'L' : '#'
      end
    end
  end
end

def build(file)
  File.readlines(file).map { |line| line.strip.chars }
end

def process(file)
  previous_grid = []
  grid = build(file)
  while different?(previous_grid, grid)
    next_grid = change(grid)
    previous_grid = grid
    grid = next_grid
  end
  grid.flatten.count('#')
end

sample_result = process('day11_sample.txt')
expected = 37

puts "Sample Result: #{sample_result}"
raise "expected: #{expected}, actual: #{sample_result}" unless sample_result == expected
puts "Result: #{process('day11.txt')}"
