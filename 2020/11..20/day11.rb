# frozen_string_literal: true

require 'byebug'
require 'readline'
require 'set'

def different?(previous_grid, grid)
  previous_grid.flatten != grid.flatten
end

def neighbours(i, j, grid)
  coords = (-1..1).map { |i| (-1..1).map { |j| [i, j] } }.reduce([]) do |arr, l|
    arr += l
  end

  coords.delete_at 4

  coords.map do |x, y|
    ni = i
    nj = j
    current = nil
    loop do
      ni += x
      nj += y
      break if ni.negative? || nj.negative? || ni >= grid.size || nj >= grid.first.size


      current = grid[ni][nj]
      break if current != '.'
    end
    current
  end
end

def change(grid)
  grid.map.with_index do |row, i|
    row.map.with_index do |seat, j|
      case seat
      when 'L'
        neighbours(i, j, grid).count('#').zero? ? '#' : 'L'
      when '#'
        neighbours(i, j, grid).count('#') >= 5 ? 'L' : '#'
      else
        '.'
      end
    end
  end
end

def build(file)
  File.readlines(file).map { |line| line.strip.chars }
end

def display(grid)
  puts "\n"
  puts grid.map { |r| r.join }.join("\n")
end

def process(file)
  previous_grid = []
  grid = build(file)
  while different?(previous_grid, grid)
    # display(grid)
    next_grid = change(grid)
    previous_grid = grid
    grid = next_grid
  end
  grid.flatten.count('#')
end

sample_result = process('day11_sample.txt')
expected = 26

puts "Sample Result: #{sample_result}"
raise "expected: #{expected}, actual: #{sample_result}" unless sample_result == expected

puts "Result: #{process('day11.txt')}"
