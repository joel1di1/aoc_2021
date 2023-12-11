# frozen_string_literal: true

require 'colorize'
require 'readline'
require 'byebug'
require 'set'
require_relative '../../fwk'

grid = File.readlines("#{__dir__}/input11.txt", chomp: true).map(&:chars)

expand_row_index = (0...grid.size).select { |row_index| grid[row_index].all? { |c| c == '.' } }
expand_col_index = (0...grid[0].size).select { |col_index| grid.all? { |row| row[col_index] == '.' } }

stars = []
# find all '#'
grid.each_with_index do |row, x|
  row.each_with_index do |col, y|
    stars << [x, y] if col == '#'
  end
end

def total_distance(stars, expand_row_index, expand_col_index, expansion)
  lengh_sum = stars[..-2].map.with_index do |star, index|
    stars[index + 1..].map do |other_star|
      distance = (other_star[0] - star[0]).abs + (other_star[1] - star[1]).abs

      # count how many time we cross a expanded row or column
      expand_rows = expand_row_index.select { |row_index| row_index.between?([star[0], other_star[0]].min, [star[0], other_star[0]].max) }.count
      expand_cols = expand_col_index.select { |col_index| col_index.between?([star[1], other_star[1]].min, [star[1], other_star[1]].max) }.count

      total = distance + (expand_rows + expand_cols) * (expansion - 1)
      # puts "star: #{stars.index(star)}, other_star: #{stars.index(other_star)}, distance: #{distance}, expand_rows: #{expand_rows}, expand_cols: #{expand_cols}, total: #{total}"
      total
    end
  end.flatten.sum
end

puts "part1: #{total_distance(stars, expand_row_index, expand_col_index, 2)}"
puts "part1: #{total_distance(stars, expand_row_index, expand_col_index, 1000000)}"
