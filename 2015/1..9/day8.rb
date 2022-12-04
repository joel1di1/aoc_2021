# frozen_string_literal: true

part1 = File.readlines('day8.txt').map(&:strip).map do |line|
  decoded_line = line[1..-2].gsub(/\\\\/, ' ').gsub(/\\"/, ' ').gsub(/\\x[a-f0-9]{2}/, ' ')
  line.size - decoded_line.size
end.sum

puts "part1: #{part1}"

part2 = File.readlines('day8.txt').map(&:strip).map do |line|
  encoded_line = line.gsub(/\\/, '  ').gsub(/"/, '  ')
  encoded_line.size - line.size + 2
end

puts "part2: #{part2.sum}"
