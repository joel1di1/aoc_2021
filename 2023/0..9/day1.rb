require 'byebug'
require 'set'
require_relative '../../fwk'

DIGITS_STR = %w[
  one
  two
  three
  four
  five
  six
  seven
  eight
  nine
].freeze

lines = File.readlines(File.join(__dir__, 'day1.txt'))

sum = lines.map do |line|
  chars = line.chars
  digits = []
  chars.each_with_index do |c, i|
    digits << c if Integer(c, exception: false)
  end

  (digits.first + digits.last).to_i
end.sum

puts "part1: #{sum}"

sum = lines.map do |line|
  chars = line.chars
  digits = []
  chars.each_with_index do |c, i|
    if Integer(c, exception: false)
      digits << c
      next
    end

    DIGITS_STR.each_with_index do |str, index|
      if line[i..].start_with?(str)
        digits << (index + 1).to_s
      end
    end

  end

  (digits.first + digits.last).to_i
end.sum

puts "part2: #{sum}"
