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

sum_six = [20, 60, 100, 140, 180, 220].map do |i| 
  puts "signal #{i}: #{signals[i-1]}"
  signals[i-1]
end.sum

puts "part 1: #{sum_six}"

# part 2

(0..239).each do |i|
  putc "\n" if i % 40 == 0 

  pos = i%40
  sprite = (register[i]-1..register[i]+1)
  inc = sprite.include?(pos)
  
  # puts "sprite: #{sprite}"
  # puts "Start cycle   #{i+1}: begin executing #{instructions[0]}"
  # puts "During cycle  #{i+1}: CRT draws pixel in position #{pos}"

  # debugger


  putc inc ? '#' : '.'
end

puts "\n"