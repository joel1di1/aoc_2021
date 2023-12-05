# frozen_string_literal: true

require 'readline'
require 'byebug'
require 'set'
require_relative '../../fwk'

def symbol?(chars, i, j)
  return false if i < 0 || i >= chars.size || j < 0 || j >= chars[i].size

  chars[i][j][/[^\d]/] && chars[i][j] != '.'
end

def part_number?(first_num, chars, i, j)
  # check up and down
  (j-1..j+first_num.size).each do |k|
    return true if symbol?(chars, i-1, k)
    return true if symbol?(chars, i+1, k)
  end

  # check left
  return true if symbol?(chars, i, j-1)

  # check right
  return true if symbol?(chars, i, j+first_num.size)

  false
end


lines = File.readlines('input3.txt').map(&:strip)

chars = lines.map(&:chars).freeze

sum = 0

(0..chars.size - 1).map do |i|
  j = 0
  while j < chars[i].size
    first_num = lines[i..][0][j..][/^\d+/]

    if first_num
      sum += first_num.to_i if part_number?(first_num, chars, i, j)
      j += first_num.size
    else
      j += 1
    end
  end
end

puts "part1: #{sum}"


sum_gear_ratio = 0

stars = Set.new
# collect stars in the chars grid
(0..chars.size - 1).map do |i|
  (0..chars[i].size - 1).map do |j|
    stars << [i, j] if chars[i][j] == '*'
  end
end

part_of_stars = {}

(0..chars.size - 1).map do |i|
  j = 0
  while j < chars[i].size
    first_num = lines[i..][0][j..][/^\d+/]

    if first_num
      # for all positions around the number
      # if the position is a star, add the number to the part of the star
      (j-1..j+first_num.size).each do |k|
        if stars.include?([i-1, k])
          part_of_stars[[i-1, k]] ||= []
          part_of_stars[[i-1, k]] << first_num.to_i
        end
        if stars.include?([i+1, k])
          part_of_stars[[i+1, k]] ||= []
          part_of_stars[[i+1, k]] << first_num.to_i
        end
      end

      if stars.include?([i, j-1])
        part_of_stars[[i, j-1]] ||= []
        part_of_stars[[i, j-1]] << first_num.to_i
      end

      if stars.include?([i, j+first_num.size])
        part_of_stars[[i, j+first_num.size]] ||= []
        part_of_stars[[i, j+first_num.size]] << first_num.to_i
      end

      j += first_num.size
    else
      j += 1
    end
  end
end

part_of_stars.map do |star, parts|
  sum_gear_ratio += parts.reduce(:*) if parts.size == 2
end

puts "part2: #{sum_gear_ratio}"
