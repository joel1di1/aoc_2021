# frozen_string_literal: true

require 'byebug'

def valid?(a,b,c)
  ((a < b + c) && (b < a+c) && (c < a+b)) ? 1 : 0
end

lines = File.readlines('day3.txt').map(&:strip)

matrix = lines.map do |line|
  line.scan(/(\d+)/).flatten.map(&:to_i)
end

sum1 = matrix.map { |row| valid?(*row) }.sum

puts "part1: #{sum1}"

sum2 = matrix.transpose.map do |row|
  row.each_slice(3).to_a.map { |slice| valid?(*slice) }.sum
end.sum

puts "part2: #{sum2}"
