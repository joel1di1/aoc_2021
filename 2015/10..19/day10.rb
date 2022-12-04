# frozen_string_literal: true

def look_and_say(str)
  str.chars.chunk(&:itself).map{|c, v| "#{v.size}#{c}" }.join  
end

def play_look_and_say_n_times(n, str)
  n.times { str = look_and_say(str) }
  str
end

input = '1321131112'

puts "part1: #{play_look_and_say_n_times(40, input).size}"
puts "part2: #{play_look_and_say_n_times(50, input).size}"
