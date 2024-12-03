require 'byebug'

lines = File.readlines(File.join(__dir__, 'input3.txt')).map(&:strip)

regexp = /mul\(\d{1,3},\d{1,3}\)/

sum = lines.map do |line|
  line.scan(regexp).map do |match|
    puts match
    match.scan(/\d{1,3}/).map(&:to_i).reduce(:*)
  end.sum
end.sum

puts "part1: #{sum}"
