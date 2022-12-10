# frozen_string_literal

require 'byebug'

instructions = File.readlines('day10.txt').map(&:strip).map do |line|
  case line
  when /addx (-?\d+)/
    $1.to_i
  else
    nil
  end
end

register = [1]

instructions.each do |instruction|
  if instruction.nil?
    register << register.last
  else
    register << register.last
    register << register.last + instruction
  end
end

# take array of numbers, return array the number multiplied by index in the array + 1
signals = register.map.with_index { |n, i| n * (i + 1) }

sum_six = [20, 60, 100, 140, 180, 220].map { |i| signals[i-1] }.sum

puts "part 1: #{sum_six}"

# part 2

(0..239).each do |i|
  pos = i%40

  putc "\n" if pos == 0 

  register_value = register[i]
  sprite = (register_value-1..register_value+1)

  putc sprite.include?(pos) ? '#' : '.'
end

puts "\n"