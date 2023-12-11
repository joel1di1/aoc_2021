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
# grid.each { |row| puts row.join }

expand_row_index = []
expand_col_index = []

(0...grid.size).each do |row_index|
  expand_row_index << row_index if grid[row_index].all? { |c| c == '.' }
end

(0...grid[0].size).each do |col_index|
  expand_col_index << col_index if grid.all? { |row| row[col_index] == '.' }
end

stars = []
# find all '#'
grid.each_with_index do |row, x|
  row.each_with_index do |col, y|
    stars << [x, y] if col == '#'
  end
end

# puts 'after inserting rows'
# # print the grid
# grid.each_with_index do |row, i|
#   row.each_with_index do |char, j|
#     print char == '#' ? stars.index([i, j]) : char
#   end
#   puts
# end


EXPANSION = 1000000

lengh_sum = stars[..-2].map.with_index do |star, index|
  stars[index + 1..].map do |other_star|
    # find the vector between the two stars
    vector = [other_star[0] - star[0], other_star[1] - star[1]]
    # find the distance between the two stars
    distance = vector[0].abs + vector[1].abs

    # count how many time we cross a expanded row or column
    expand_rows = expand_row_index.select { |row_index| row_index.between?([star[0], other_star[0]].min, [star[0], other_star[0]].max) }.count
    expand_cols = expand_col_index.select { |col_index| col_index.between?([star[1], other_star[1]].min, [star[1], other_star[1]].max) }.count

    total = distance + (expand_rows + expand_cols) * (EXPANSION - 1)
    # puts "star: #{stars.index(star)}, other_star: #{stars.index(other_star)}, distance: #{distance}, expand_rows: #{expand_rows}, expand_cols: #{expand_cols}, total: #{total}"
    total
  end
end.flatten.sum

puts "part1: #{lengh_sum}"
