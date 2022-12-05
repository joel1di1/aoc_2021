# frozen_string_literal: true

require 'byebug'

keypad = [
  %w[7 8 9],
  %w[4 5 6],
  %w[1 2 3]
]

lines = File.readlines('day2.txt')

steps = {
  'U' => [1, 0],
  'D' => [-1, 0],
  'L' => [0, -1],
  'R' => [0, 1]
}

pos = [1, 1]

code = []
lines.map do |line|
  line.strip.chars.each do |char|
    pos = pos.zip(steps[char]).map do |a, b|
      sum = a + b
      sum = [0, sum].max
      [2, sum].min
    end
  end
  code << keypad[pos[0]][pos[1]]
end

puts "part1: #{code.join}"