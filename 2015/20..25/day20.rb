# frozen_string_literal: true

require 'byebug'
require 'set'
require_relative '../../fwk'

class Numeric
  def divisible_by?(divisor)
    self % divisor == 0
  end
end

def nb_presents(door_number)
  (1..door_number).map do |i|
    door_number.divisible_by?(i) ? i*10 : 0
  end.sum
end

assert_eq(10, nb_presents(1), msg: "House 1 got 10 presents.")
assert_eq(30, nb_presents(2), msg: "House 2 got 30 presents.")
assert_eq(40, nb_presents(3), msg: "House 3 got 40 presents.")
assert_eq(70, nb_presents(4), msg: "House 4 got 70 presents.")
assert_eq(60, nb_presents(5), msg: "House 5 got 60 presents.")
assert_eq(120, nb_presents(6), msg: "House 6 got 120 presents.")
assert_eq(80, nb_presents(7), msg: "House 7 got 80 presents.")
assert_eq(150, nb_presents(8), msg: "House 8 got 150 presents.")
assert_eq(130, nb_presents(9), msg: "House 9 got 130 presents.")


# i = 46672

# target = 33100000
# 33100000
# 3080160

# return an array of all factors of the number num
def sum_factors(num)
  factors = []
  (1..Math.sqrt(num)).each do |i|
    if num % i == 0
      factors << i
      factors << num / i unless i == num / i
    end
  end
  factors.sum
end

target = 3310000

i=0

until sum_factors(i) == target
  i +=1
  puts("i: #{i}, nb_presents: #{sum_factors(i)}")
end

# puts "part1: #{i}"
189096
