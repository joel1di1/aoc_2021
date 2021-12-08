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

  invalid_pos = (preamble..numbers.count).find do |index|
    !sum_in?(numbers[index], numbers[index - preamble, index])
  end
  invalid = numbers[invalid_pos]

  puts "invalid: #{invalid}"

  (0..numbers.length - 2).each do |start_index|
    ((start_index + 1)..numbers.length).each do |end_index|
      contiguous = numbers[start_index..end_index+1]
      break if contiguous.sum > invalid

      return contiguous.min + contiguous.max if contiguous.sum == invalid
    end
  end
  'KO'
end

sample_result = process('day9_sample.txt', 5)
expected = 62

puts "Sample Result: #{sample_result}"

raise "expected: #{expected}, actual: #{sample_result}" unless sample_result == expected

puts "Result: #{process('day9.txt')}"

