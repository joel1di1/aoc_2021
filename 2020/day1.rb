# frozen_string_literal: true

require 'readline'

numbers = File.readlines('day1.txt').map(&:to_i).sort

numbers.each_with_index do |n1, i|
  loop do
    n2 = numbers[i]
    break if n2.nil?
    break if n2 + n1 > 2020
    puts(n1 * n2) if n1 + n2 == 2020
    i += 1
  end
end
