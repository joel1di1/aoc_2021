require 'byebug'
require 'set'
require_relative '../../fwk'

lines = File.readlines(File.join(__dir__, 'input1.txt'))

lefts = []
rights = []

lines.each do |line|
  left, right = line.split(' ')
  lefts << left.to_i
  rights << right.to_i
end

lefts_sorted = lefts.sort
rights_sorted = rights.sort

distance = 0
(0..lines.size - 1).each do |i|
  distance += (lefts_sorted[i] - rights_sorted[i]).abs
end

puts "part1: #{distance}"

similarity = 0


def occurences_of(num, arr)
  arr.count { |n| n == num }
end

(0..lefts.size - 1).each do |i|
  nb_occurences = occurences_of(lefts[i], rights)
  similarity += nb_occurences * lefts[i]
end

puts "part2: #{similarity}"
