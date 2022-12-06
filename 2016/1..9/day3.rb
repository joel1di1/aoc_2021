# frozen_string_literal: true

require 'byebug'

# read triangle in a file, each triangle is a line.
# each line hase 3 numbers, representing 3 side

triangles = File.readlines('day3.txt').map do |line|
  line.strip.split.map(&:to_i)
end

# part 1
# each triangle is a line, so we can just check if the sum of the 2 smallest
# sides is greater than the largest side

valid_triangles = triangles.select do |triangle|
  triangle.sort[0..1].sum > triangle.sort[2]
end

puts "part1: #{valid_triangles.count}"

# part 2

valid_triangles = triangles.transpose.flatten.each_slice(3).select do |triangle|
  triangle.sort[0..1].sum > triangle.sort[2]
end

puts "part2: #{valid_triangles.count}"
