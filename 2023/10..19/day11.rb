# frozen_string_literal: true

require 'colorize'
require 'readline'
require 'byebug'
require 'set'
require_relative '../../fwk'

# read input11.txt and construct a grid with the chars

grid = []

File.open('input11.txt').each do |line|
  grid << line.chomp.chars
end

# print the grid
grid.each { |row| puts row.join }

row_index = 0
until row_index == grid.size
  row = grid[row_index]
  if row.all? { |c| c == '.' }
    grid.insert(row_index, row.dup)
    row_index += 1
  end
  row_index += 1
end

col_index = 0
until col_index == grid[0].size
  col = grid.map { |row| row[col_index] }
  if col.all? { |c| c == '.' }
    grid.each do |row|
      row.insert(col_index, '.')
    end
    col_index += 1
  end
  col_index += 1
end

puts 'after inserting rows'
# print the grid
grid.each do |row|
  puts row.join
end


stars = []
# find all '#'
grid.each_with_index do |row, y|
  row.each_with_index do |col, x|
    stars << [x, y] if col == '#'
  end
end

lengh_sum = stars[..-2].map.with_index do |star, index|
  stars[index + 1..].map do |other_star|
    # find the vector between the two stars
    vector = [other_star[0] - star[0], other_star[1] - star[1]]
    # find the distance between the two stars
    distance = vector[0].abs + vector[1].abs
    distance
  end
end.flatten.sum

puts "part1: #{lengh_sum}"
