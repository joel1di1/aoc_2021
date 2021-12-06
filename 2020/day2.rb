# frozen_string_literal: true

require 'readline'

lines = File.readlines('day2.txt')

def extract_infos(line)
  a = line.split
  min, max = a.first.split('-').map(&:to_i)
  char = a[1][0]
  password = a[2]
  [char, min, max, password]
end

selected_lines = lines.select do |line|
  char, min, max, password = extract_infos(line)

  tally = password.chars.tally

  tally[char] && min <= tally[char] && tally[char] <= max
end

puts "Part 1: #{selected_lines.count}"

selected_lines = lines.select do |line|
  char, position1, position2, password = extract_infos(line)
  [position1, position2].map{|p| password[p - 1]}.select { |c| c == char }.count == 1
end

puts "Part 2: #{selected_lines.count}"
