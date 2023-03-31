# frozen_string_literal: true

input = File.readlines('day4.txt', chomp: true)

# Define a method that checks if two ranges overlap
def overlap?(range1, range2)
  range1.first <= range2.last && range2.first <= range1.last
end

count = 0

# Iterate over each line of the input file
input.each do |line|
  # Split the line into two range strings
  left_range_str, right_range_str = line.split(',')

  # Convert each range string to an array of integers
  left_range_arr = left_range_str.split('-').map(&:to_i)
  right_range_arr = right_range_str.split('-').map(&:to_i)

  # Convert the integer arrays to range objects
  left_range = Range.new(*left_range_arr)
  right_range = Range.new(*right_range_arr)

  # Check if the left and right ranges overlap
  if overlap?(left_range, right_range)
    count += 1
  end
end

puts count
