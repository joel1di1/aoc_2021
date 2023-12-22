# frozen_string_literal: true

require 'colorize'
require 'readline'
require 'byebug'
require 'set'
require_relative '../../fwk'

grid = File.readlines('input21.txt', chomp: true).map(&:chars)

# convert grid to hash
grid_h = {}
start = nil
grid.each_with_index do |row, x|
  row.each_with_index do |cell, y|
	grid_h[[x, y]] = cell
	start = [x, y] if cell == 'S'
  end
end

def display(grid_h, positions = [])
  (0..grid_h.keys.map(&:first).max).each do |x|
  	(0..grid_h.keys.map(&:last).max).each do |y|
      if positions.include?([x, y])
        print 'O'.red
      else
  	   print grid_h[[x, y]]
     end
  	end
  	puts
  end
end

display(grid_h)
puts start.inspect

def next_pos(positions, grid_h)
  candidates = positions.map do |pos|
    [[pos[0] + 1, pos[1]], [pos[0] - 1, pos[1]], [pos[0], pos[1] + 1], [pos[0], pos[1] - 1]]
  end.flatten(1).uniq

  candidates.select do |pos|
    ['.', 'S'].include?(grid_h[pos])
  end
end

def next_pos_rec(positions, loop_count, grid_h)
  loop_count.times do
    positions = next_pos(positions, grid_h)

    display(grid_h, positions)
    puts
  end
  positions
end

res = next_pos_rec([start], 64, grid_h)

puts res.size