# frozen_string_literal: true
require 'readline'

def read_input_lines
  File.readlines(File.basename(__FILE__).gsub('.rb', '.txt'))
end


# split array of integer into array of array of integer on each 0
def split_on_zero(numbers)
  acc = []
  acc << []
  numbers.each do |n|
    if n == 0
      acc << []
    else
      acc.last << n
    end
  end
  acc
end

def sum_of_top_three_numbers(numbers)
  numbers.sort.reverse.take(3).sum
end

arrays = split_on_zero(read_input_lines.map(&:to_i))
sums = arrays.map(&:sum)
puts "1st part: #{sums.max}"

puts "2nd part: #{sum_of_top_three_numbers(sums)}"
