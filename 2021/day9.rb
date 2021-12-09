# frozen_string_literal: true

require 'readline'
require 'byebug'

def process(file)
  grid = File.readlines(file).map { |line| line.strip.chars.map(&:to_i) }

  low_point_indexes = []
  (0..grid.size - 1).each do |i|
    (0..grid.first.size - 1).each do |j|
      coords = (-1..1).map { |x| (-1..1).map { |y| [i+x, j+y] } }.reduce(:+).select do |x, y|
        x >= 0 && y >= 0 && x <= grid.size - 1 && y <= grid.first.size - 1
      end

      min = coords.map { |x, y| grid[x][y] }.min
      low_point_indexes << [i, j] if grid[i][j] == min
      # puts "low_point_indexes: #{low_point_indexes}"
    end
  end

  low_point_indexes.map do |x, y|
    grid[x][y] + 1
  end.sum
end

puts "Sample: #{process('day9_sample.txt')}"
puts "res: #{process('day9.txt')}"