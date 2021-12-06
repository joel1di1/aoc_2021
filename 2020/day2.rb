# frozen_string_literal: true

require 'readline'

lines = File.readlines('day2.txt')

selected_lines = lines.select do |line|
  a = line.split
  min, max = a.first.split('-').map(&:to_i)
  char = a[1][0]
  password = a[2]

  tally = password.chars.tally

  tally[char] && min <= tally[char] && tally[char] <= max
end

puts selected_lines

puts lines.count

puts selected_lines.count