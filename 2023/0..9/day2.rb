# frozen_string_literal: true

require 'readline'
require 'byebug'
require 'set'
require_relative '../../fwk'

def read_input(filename)
  lines = File.readlines(filename).map(&:strip)
  lines.map do |line|
    _, right = line.split(':').map(&:strip)

    right.split(';').map(&:strip).map do |sets|
      sets.split(',').map(&:strip).map do |set|
        num, color = set.split(' ')
        [color, num.to_i]
      end.to_h
    end
  end
end

games = read_input('input2.txt')

max_cubes = { 'red' => 12, 'green' => 13, 'blue' => 14 }

sum = games.map.with_index do |sets, index|
  valid = true
  sets.each do |set|
    set.each do |color, num|
      valid = false if num > max_cubes[color]
    end
  end

  valid ? index + 1 : 0
end.sum

puts "part1: #{sum}"

powers = games.map do |sets|
  minimums = { 'red' => 0, 'green' => 0, 'blue' => 0 }

  sets.each do |set|
    set.each do |color, num|
      minimums[color] = num if num > minimums[color]
    end
  end

  minimums.values.inject(:*)
end

puts "part2: #{powers.sum}"
