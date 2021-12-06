# frozen_string_literal: true

require 'readline'

def build_forest(file)
  File.readlines(file).map{|l| l.strip.chars }
end

def process(file)
  forest = build_forest(file)
  width = forest.first.size
  path = (0..forest.size - 1).map do |i|
    y = (3 * i) % width
    forest[i][y]
  end
  puts "#{file}: #{path.select{ |p| p == '#' }.count}"
end

process('day3_sample.txt')
process('day3.txt')
