# frozen_string_literal: true

require 'readline'
require 'byebug'
require 'set'
require_relative '../../fwk'

lines = File.readlines("#{__dir__}/input6.txt", chomp: true)

times = lines.first.split(':')[1].strip.split.map(&:to_i)
distances = lines[1].split(':')[1].strip.split.map(&:to_i)

def ways_to_win(time, distance)
  ways_to_win = (0..time).to_a.map do |push_time|
    travel_time = time - push_time
    push_time * travel_time > distance ? 1 : 0
  end.sum
end

all_ways_to_win = (0..times.size - 1).to_a.map do |i|
  time = times[i]
  distance = distances[i]

  # nb of way to win
  ways_to_win(time, distance)
end

puts all_ways_to_win.inject(:*)

# Part 2
time = lines.first.split(':')[1].strip.gsub(' ', '').to_i
distance = lines[1].split(':')[1].strip.gsub(' ', '').to_i

puts "Time: #{time}, Distance: #{distance}"

puts ways_to_win(time, distance)
