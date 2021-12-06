# frozen_string_literal: true

require 'readline'

numbers = File.readlines('day1.txt').map(&:to_i).sort

numbers.each_with_index do |n1, i|
  loop do
    n2 = numbers[i]
    break if n2.nil?
    break if n2 + n1 > 2020

    puts("with 2: #{n1 * n2}") if n1 + n2 == 2020
    i += 1
  end
end

# part 2

numbers.each_with_index do |n1, i|
  loop do
    n2 = numbers[i]
    break if n2.nil?

    j = i + 1
    loop do
      n3 = numbers[j]
      break if n3.nil?
      break if n3 + n2 + n1 > 2020

      puts(n1 * n2 * n3) if n1 + n2 + n3== 2020
      j += 1
    end
    i+=1
  end
end


