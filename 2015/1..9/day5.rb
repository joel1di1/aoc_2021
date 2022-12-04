# frozen_string_literal: true

def nice?(str)
  return false if str =~ /ab|cd|pq|xy/
  return false if str.scan(/[aeiou]/).size < 3
  return false if str.scan(/(.)\1/).empty?
  true
end

def nice2?(str)
  return false if str.scan(/(..).*\1/).empty?
  return false if str.scan(/(.).\1/).empty?
  true
end

def part1 
  File.readlines('day5.txt').map(&:strip).count { |str| nice?(str) }
end

def part2
  File.readlines('day5.txt').map(&:strip).count { |str| nice2?(str) }
end

puts "part1: #{part1}"
puts "part2: #{part2}"
