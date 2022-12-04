# frozen_string_literal: true

require 'set'

positions = Set.new
current = [0, 0]
positions << current.dup
File.open('day3.txt', 'r') do |f|
  f.each_char do |c|
    case c
    when '^'
      current[1] += 1
    when 'v'
      current[1] -= 1
    when '>'
      current[0] += 1
    when '<'
      current[0] -= 1
    end
    positions << current.dup
  end
end
puts "part1: #{positions.size}"

santa = [0, 0]
robo = [0, 0]
positions = Set.new
positions << santa.dup
positions << robo.dup

File.open('day3.txt', 'r') do |f|
  f.each_char.with_index do |c, i|
    current = i.even? ? santa : robo
    case c
    when '^'
      current[1] += 1
    when 'v'
      current[1] -= 1
    when '>'
      current[0] += 1
    when '<'
      current[0] -= 1
    end
    positions << current.dup
  end
end
puts "part2: #{positions.size}"
