require 'readline'

lines = File.readlines('inputs/day3.txt')

byte_array = lines.map{|line| line.strip.bytes.map{|b| b-48} }

@length = byte_array.first.length
sums = Array.new(@length, 0)

(0..@length-1).each do |i|
  byte_array.each do |byte|
    sums[i] += byte[i]
  end
end

gamma_rate = sums.map{|b| b > (lines.count/2) ? 1 : 0}.join.to_i(2)
epsilon_rate = sums.map{|b| b < (lines.count/2) ? 1 : 0}.join.to_i(2)

pp "Consumption: #{gamma_rate * epsilon_rate}"


def find_most_common(byte_array, position)
  zeros = 0
  ones = 0
  byte_array.each { |byte| byte[position] == 1 ? (ones += 1) : (zeros += 1)}

  ones >= zeros ? 1 : 0
  # byte_array.map { |byte| byte[position]}.reduce(:+) >= (byte_array.length/2) ? 1 : 0
end

def find_least_common(byte_array, position)
  zeros = 0
  ones = 0
  byte_array.each { |byte| byte[position] == 1 ? (ones += 1) : (zeros += 1)}

  ones < zeros ? 1 : 0
  # byte_array.map { |byte| byte[position]}.reduce(:+) <= (byte_array.length/2) ? 1 : 0
end


def filter(byte_array, value, position)
  byte_array.select{|byte| byte[position] == value}
end

def determine_oxygen_generator_rating(byte_array, position)
  if byte_array.length == 1
    return byte_array.first.join.to_i(2)
  end

  most_common = find_most_common(byte_array, position)
  filtered_byte_array = filter(byte_array, most_common, position)
  determine_oxygen_generator_rating(filtered_byte_array, position + 1)
end

def determine_co2_scrubber_rating(byte_array, position)
  raise if position >= @length
  return byte_array.first.join.to_i(2) if byte_array.length == 1

  least_common = find_least_common(byte_array, position)
  filtered_byte_array = filter(byte_array, least_common, position)
  determine_co2_scrubber_rating(filtered_byte_array, position + 1)
end

oxygen_generator_rating = determine_oxygen_generator_rating(byte_array, 0)
pp oxygen_generator_rating

co2_scrubber_rating = determine_co2_scrubber_rating(byte_array, 0)
pp co2_scrubber_rating

pp(oxygen_generator_rating * co2_scrubber_rating)
