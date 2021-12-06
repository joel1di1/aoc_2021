# frozen_string_literal: true

require 'readline'

def build_forest(file)
  File.readlines(file).map{|l| l.strip.chars }
end

def count_trees(file, right, down = 1)
  forest = build_forest(file)
  width = forest.first.size
  x = 0
  y = 0
  path = []
  while x < forest.size
    path << forest[x][y]
    x += down
    y = (y + right) % width
  end
  trees_sum = path.select{ |p| p == '#' }.count
  puts "#{file}: #{trees_sum}"
  trees_sum
end

count_trees('day3_sample.txt', 3, 1)
count_trees('day3.txt', 3, 1)

total = [[1, 1],
 [3, 1],
 [5, 1],
 [7, 1],
 [1, 2]].map do |right, down|
  count_trees('day3.txt', right , down)
end.reduce(:*)


puts total