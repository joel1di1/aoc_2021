# frozen_string_literal: true

require 'colorize'
require 'readline'
require 'byebug'
require 'set'
require_relative '../../fwk'

GRID = File.readlines('input21.txt', chomp: true).map(&:chars)

# convert grid to hash
grid_h = {}
start = nil
GRID.each_with_index do |row, x|
  row.each_with_index do |cell, y|
	grid_h[[x, y]] = cell
	start = [x, y] if cell == 'S'
  end
end

puts "grid size: #{GRID.size}, #{GRID.first.size}"

def display(grid_h, positions = [])
  min_x = [0, positions.map(&:first).min].min
  min_y = [0, positions.map(&:last).min].min
  max_x = [11, positions.map(&:first).max].max
  max_y = [11, positions.map(&:last).max].max

  (min_x..max_x).each do |x|
  	(min_y..max_y).each do |y|
      if positions.include?([x, y])
        print 'O'.red
      else
  	   print grid_h[[x % GRID.size, y % GRID.first.size]]
     end
  	end
  	puts
  end

  puts
end

def not_rock?(position, grid_h)
  ['.', 'S'].include?(grid_h[[position.first % GRID.size, position.last % GRID.first.size]])
end

def next_pos(positions, grid_h)
  candidates = positions.map do |pos|
    [[pos[0] + 1, pos[1]], [pos[0] - 1, pos[1]], [pos[0], pos[1] + 1], [pos[0], pos[1] - 1]]
  end.flatten(1).uniq

  candidates.select do |pos|
    not_rock?(pos, grid_h)
  end
end

def next_pos_rec(positions, loop_count, grid_h)
  loop_count.times do |i|
    
    positions = next_pos(positions, grid_h)

    if i%GRID.size == GRID.size/2-1
      puts "#{i}\t#{positions.size}"
      display(grid_h, positions) 
    end

  end
  positions
end

res = next_pos_rec([start], 500, grid_h)

# puts res.size