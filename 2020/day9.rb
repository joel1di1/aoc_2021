# frozen_string_literal: true

require 'byebug'
require 'readline'
require 'solid_assert'

def sum_in?(num, previous)
  (0..previous.size - 1).each do |i|
    (0..previous.size - 1).each do |j|
      return true if i != j && previous[i] + previous[j] == num
    end
  end
  false
end

def process(file, preamble = 25)
  numbers = File.readlines(file).map(&:to_i)

  (preamble..numbers.count).each do |index|
    return numbers[index] unless sum_in?(numbers[index], numbers[index - preamble, index])
  end
end


sample_result = process('day9_sample.txt', 5)
expected = 127

raise "expected: #{expected}, actual: #{sample_result}" unless sample_result == expected

puts "Result: #{process('day9.txt')}"