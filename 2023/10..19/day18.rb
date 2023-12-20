# frozen_string_literal: true

require 'colorize'
require 'readline'
require 'byebug'
require 'set'
require_relative '../../fwk'

lines = File.readlines("#{__dir__}/input18.txt", chomp: true)

# 0 => R, 1 => D, 2 => L, and 3 => U.

instructions = lines.map do |line|
	hexa_dist, direction = line.scan(/^\w \d+ \(#(.*)(.)\)$/)[0]
	["0x#{hexa_dist}".to_i(16), direction.to_i]
end

puts instructions.inspect

# grid = {}

# grid[ [0, 0] ] = instructions.first[2]

# def display(grid)
# 	keys = grid.keys
# 	min_x = keys.map(&:first).sort.first
# 	max_x = keys.map(&:first).sort.last
# 	min_y = keys.map(&:last).sort.first
# 	max_y = keys.map(&:last).sort.last

# 	(min_x-2..max_x).each do |x|
# 		(min_y-2..max_y).each do |y|
# 			if grid[[x,y]] == '%'
# 				print '#'.red
# 			elsif grid[[x,y]]
# 				print '#'
# 			else
# 				print '.'
# 			end
# 		end
# 		puts
# 	end
# 	puts
# end


# current = [0, 0]
# instructions.each do |direction, steps, color|
# 	steps = steps.to_i
# 	steps.times do
# 		case direction
# 		when 'U'
# 			current = [current[0] - 1, current[1]]
# 		when 'D'
# 			current = [current[0] + 1, current[1]]
# 		when 'L'
# 			current = [current[0], current[1] - 1]
# 		when 'R'
# 			current = [current[0], current[1] + 1]
# 		end
# 		grid[current] = color
# 	end
# end

# display(grid)

# def fill_inside(grid)
# 	keys = grid.keys
# 	min_x = keys.map(&:first).sort.first
# 	max_x = keys.map(&:first).sort.last
# 	min_y = keys.map(&:last).sort.first
# 	max_y = keys.map(&:last).sort.last

# 	current_x = (max_x+min_x) / 2
# 	current_y = (max_y+min_y) / 2

# 	current_x += 1 until grid[[current_x, current_y]]

# 	current_x -= 1 # now we're inside  

# 	to_mark = []
# 	to_mark << [current_x, current_y]

# 	until to_mark.empty?
# 		current = to_mark.pop
		
# 		next if grid[current]

# 		grid[current] = '%'
# 		# display(grid)

# 		puts "grid: #{grid.size}"


# 		[[-1, 0], [1, 0], [0, -1], [0, 1]].each do |dx, dy|
# 			neighbor = [current[0] + dx, current[1] + dy]
# 			to_mark << neighbor if grid[neighbor].nil?
# 		end
# 	end
# end

# fill_inside(grid)

# puts

# display(grid)

# puts "part1: #{grid.size}"