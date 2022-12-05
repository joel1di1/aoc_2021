# frozen_string_literal: true

require 'byebug'

keypad = [
  [nil, nil, 'D', nil, nil],
  [nil, 'A', 'B', 'C', nil],
  ['5', '6', '7', '8', '9'],
  [nil, '2', '3', '4', nil],
  [nil, nil, '1', nil, nil],
]

lines = File.readlines('day2.txt')

steps = {
  'U' => [1, 0],
  'D' => [-1, 0],
  'L' => [0, -1],
  'R' => [0, 1]
}

pos = [2, 0]

code = []
lines.map do |line|
  line.strip.chars.each do |char|
    new_pos = pos.zip(steps[char]).map do |a, b|
      sum = a + b
      sum = [0, sum].max
      [4, sum].min
    end
    pos = new_pos if keypad[new_pos[0]] && keypad[new_pos[0]][new_pos[1]]
  end
  code << keypad[pos[0]][pos[1]]
end

puts "part2: #{code.join}"