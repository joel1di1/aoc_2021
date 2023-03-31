# frozen_string_literal: true

input = File.readlines('day4.txt', chomp: true)

count = 0

# Iterate over each line of the input file
input.each do |line|
  # Split the line into two range strings
  left_range_str, right_range_str = line.split(',')

  # Convert each range string to an array of integers
  left_range_arr = left_range_str.split('-').map(&:to_i)
  right_range_arr = right_range_str.split('-').map(&:to_i)

  # Create range objects from the arrays of integers
  left_range = Range.new(*left_range_arr)
  right_range = Range.new(*right_range_arr)

  # Check if either the left range is fully contained in the right range,
  # or the right range is fully contained in the left range
  if left_range.cover?(right_range.first) && left_range.cover?(right_range.last) ||
     right_range.cover?(left_range.first) && right_range.cover?(left_range.last)
    # If so, increment the count of overlapping pairs
    count += 1
  end
end

puts count
