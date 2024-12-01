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

lefts.sort!
rights.sort!

distance = 0
(0..lines.size - 1).each do |i|
  distance += (lefts[i] - rights[i]).abs
end

puts "part1: #{distance}"
