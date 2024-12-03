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

regexp = /mul\(\d{1,3},\d{1,3}\)|do\(\)|don't\(\)/

enabled = true
sum = lines.map do |line|
  line.scan(regexp).map do |match|
    if match == "do()"
      enabled = true
      0
    elsif match == "don't()"
      enabled = false
      0
    else
      enabled ? match.scan(/\d{1,3}/).map(&:to_i).reduce(:*) : 0
    end
  end.sum
end.sum

puts "part2: #{sum}"
