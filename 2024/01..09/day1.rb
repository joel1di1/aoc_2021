require_relative '../../fwk'

lines = File.readlines(File.join(__dir__, 'input1.txt'))

lefts, rights = lines.map { |line| line.split.map(&:to_i) }.transpose

distance = lefts.sort.zip(rights.sort).sum { |left, right| (left - right).abs }

puts "part1: #{distance}"

similarity = lefts.sum { |left| rights.count(left) * left }

puts "part2: #{similarity}"
