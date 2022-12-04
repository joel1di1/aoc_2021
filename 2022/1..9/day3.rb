# frozen_string_literal: true

commons = File.readlines('day3.txt').map do |line|
  # split string in 2 parts of equal length
  left = line[0..line.length / 2 - 1]
  right = line[line.length / 2..]

  # find charaters that appears in both strings
  left.chars.find { |c| right.include?(c) }
end

sum = commons.map do |c|
  c == c.downcase ? c.ord - 'a'.ord + 1 : c.ord - 'A'.ord + 27
end.sum

puts "part1: #{sum}"

# part 2
lines = File.readlines('day3.txt')

# group lines in groups of 3
commons = lines.each_slice(3).to_a.map do |rucksacks|
  # for each group, find the caracter that appears in all 3 lines
  rucksacks[0].chars.find do |c|
    rucksacks[1].include?(c) && rucksacks[2].include?(c)
  end
end

sum = commons.map do |c|
  c == c.downcase ? c.ord - 'a'.ord + 1 : c.ord - 'A'.ord + 27
end.sum

puts "part2: #{sum}"
