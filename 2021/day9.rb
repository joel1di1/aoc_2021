# frozen_string_literal: true

require 'readline'
require 'byebug'
require 'set'

def bassin(grid, i, j, current_bassin = Set.new)
  return if current_bassin.include? [i, j]
  return if grid[i][j] == 9

  current_bassin << [i, j]
  coords = [[i, j-1], [i, j+1], [i-1,j], [i+1,j]].select do |x, y|
    x >= 0 && y >= 0 && x <= grid.size - 1 && y <= grid.first.size - 1
  end

  coords.each do |x, y|
    next if current_bassin.include? [x, y]
    next if grid[x][y] == 9

    if grid[i][j] < grid[x][y]
      bassin(grid, x, y, current_bassin)
    end
  end
  current_bassin
end

def process(file)
  grid = File.readlines(file).map { |line| line.strip.chars.map(&:to_i) }

  low_point_indexes = []
  (0..grid.size - 1).each do |i|
    (0..grid.first.size - 1).each do |j|
      coords = (-1..1).map { |x| (-1..1).map { |y| [i + x, j + y] } }.reduce(:+).select do |x, y|
        x >= 0 && y >= 0 && x <= grid.size - 1 && y <= grid.first.size - 1
      end

      min = coords.map { |x, y| grid[x][y] }.min
      low_point_indexes << [i, j] if grid[i][j] == min
      # puts "low_point_indexes: #{low_point_indexes}"
    end
  end

  bassins_sizes = low_point_indexes.map do |x, y|
    bassin(grid, x, y).size
  end
  bassins_sizes.sort[-3..].reduce(:*)
end

puts "Sample: #{process('day9_sample.txt')}"
puts "res: #{process('day9.txt')}"