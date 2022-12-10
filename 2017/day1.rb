# advent of code 2017 day 1 part 1

# --- Day 1: Inverse Captcha ---

# read input from day1.txt

input = File.read('day1.txt')

# part 1

# The captcha requires you to review a sequence of digits (your puzzle input) and find the sum of all digits that match the next digit in the list. The list is circular, so the digit after the last digit is the first digit in the list.

# For example:

# 1122 produces a sum of 3 (1 + 2) because the first digit (1) matches the second digit and the third digit (2) matches the fourth digit.

# 1111 produces 4 because each digit (all 1) matches the next.

# 1234 produces 0 because no digit matches the next.

# 91212129 produces 9 because the only digit that matches the next one is the last digit, 9.

# What is the solution to your captcha?

def solve(input)
  input.chars.map(&:to_i).each_cons(2).select { |a, b| a == b }.map(&:first).sum + (input[0] == input[-1] ? input[0].to_i : 0)
end

puts "part1: #{solve(input)}"

# part 2

# You notice a progress bar that jumps to 50% completion. Apparently, the door isn't yet satisfied, but it did emit a star as encouragement. The instructions change:

# Now, instead of considering the next digit, it wants you to consider the digit halfway around the circular list. That is, if your list contains 10 items, only include a digit in your sum if the digit 10/2 = 5 steps forward matches it. Fortunately, your list has an even number of elements.

# For example:

# 1212 produces 6: the list contains 4 items, and all four digits match the digit 2 items ahead.

# 1221 produces 0, because every comparison is between a 1 and a 2.

# 123425 produces 4, because both 2s match each other, but no other digit has a match.

# 123123 produces 12.

# 12131415 produces 4.

# What is the solution to your new captcha?

def solve_part2(input)
  (input.chars.map(&:to_i).each_cons(input.length / 2).select { |a, b| a == b }.map(&:first).sum * 2) + (input[0] == input[input.length / 2] ? input[0].to_i : 0)
end

puts "part2: #{solve_part2(input)}"

# take a string, reverse it, and add count the number of similar characters

class Point
  attr_accessor :x, :y
  def initialize(x, y)
    @x = x
    @y = y
  end

  def ==(other)
    @x == other.x && @y == other.y
  end

  # multiply params by 2 and translate
  def translate(dx, dy)
    @x += dx * 2
    @y += dy * 2
  end
end



def reverse_and_count(input)
  input.chars.reverse.join.chars.each_cons(2).select { |a, b| a == b }.map(&:first).sum + (input[0] == input[-1] ? input[0].to_i : 0)
end

