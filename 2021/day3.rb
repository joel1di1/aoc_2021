# frozen_string_literal: true

require 'readline'

lines = File.readlines('inputs/day3.txt')

byte_array = lines.map { |line| line.strip.bytes.map { |b| b - 48 } }

@length = byte_array.first.length
sums = Array.new(@length, 0)

(0..@length - 1).each do |i|
  byte_array.each do |byte|
    sums[i] += byte[i]
  end
end

mid_point = (lines.count.to_f / 2)
gamma_rate = sums.map { |b| b > mid_point ? 1 : 0 }.join.to_i(2)
epsilon_rate = sums.map { |b| b < mid_point ? 1 : 0 }.join.to_i(2)

puts "Consumption: #{gamma_rate * epsilon_rate}"

def find_common(byte_array, position, order)
  one_more_present = byte_array.map { |byte| byte[position] }.reduce(:+) >= (byte_array.length.to_f / 2)
  (order == :most && one_more_present) || (order == :least && !one_more_present)
end

def filter(byte_array, match_value, position)
  byte_array.select { |byte| !byte[position].zero? == match_value }
end

def determine_rating(byte_array, order, position = 0)
  return byte_array.first.join.to_i(2) if byte_array.length == 1

  common = find_common(byte_array, position, order)
  filtered_byte_array = filter(byte_array, common, position)
  determine_rating(filtered_byte_array, order, position + 1)
end

def determine_oxygen_generator_rating(byte_array)
  determine_rating(byte_array, :most)
end

def determine_co2_scrubber_rating(byte_array)
  determine_rating(byte_array, :least)
end

oxygen_generator_rating = determine_oxygen_generator_rating(byte_array)
co2_scrubber_rating = determine_co2_scrubber_rating(byte_array)

puts "life support rating: #{oxygen_generator_rating * co2_scrubber_rating}"
