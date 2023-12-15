# frozen_string_literal: true

require 'colorize'
require 'readline'
require 'byebug'
require 'set'
require_relative '../../fwk'

grid = File.readlines("#{__dir__}/input14.txt", chomp: true).map(&:chars)

def display_grid(grid)
  grid.each do |row|
    puts row.join
  end
  puts
end

def tilt_north(grid)
  # iterate on columns
  (0...grid[0].size).each do |col_index|
    # start from the bottom
    row_index = grid[0].size - 1
    rocks = 0

    until row_index < 0
      current = grid[row_index][col_index]
      case current
      when 'O'
        grid[row_index][col_index] = '.'
        rocks += 1
      when '.'
      when '#'
        (0...rocks).each do |i|
          grid[row_index + 1 + i][col_index] = 'O'
        end
        rocks = 0
      else
        raise "Unexpected #{current}"
      end
      row_index -= 1
    end

    (0...rocks).each do |i|
      grid[row_index + 1 + i][col_index] = 'O'
    end
  end
end

def tilt_south(grid)
  # iterate on columns
  (0...grid[0].size).each do |col_index|
    # start from the top
    row_index = 0
    rocks = 0

    until row_index >= grid[0].size
      current = grid[row_index][col_index]
      case current
      when 'O'
        grid[row_index][col_index] = '.'
        rocks += 1
      when '.'
      when '#'
        (0...rocks).each do |i|
          grid[row_index - 1 - i][col_index] = 'O'
        end
        rocks = 0
      else
        raise "Unexpected #{current}"
      end
      row_index += 1
    end

    (0...rocks).each do |i|
      grid[row_index - 1 - i][col_index] = 'O'
    end
  end
end

def tilt_west(grid)
  # iterate on rows
  (0...grid.size).each do |row_index|
    # start from the right
    col_index = grid.size - 1
    rocks = 0

    until col_index < 0
      current = grid[row_index][col_index]
      case current
      when 'O'
        grid[row_index][col_index] = '.'
        rocks += 1
      when '.'
      when '#'
        (0...rocks).each do |i|
          grid[row_index][col_index + 1 + i] = 'O'
        end
        rocks = 0
      else
        raise "Unexpected #{current}"
      end
      col_index -= 1
    end

    (0...rocks).each do |i|
      grid[row_index][col_index + 1 + i] = 'O'
    end
  end
end

def tilt_east(grid)
  # iterate on rows
  (0...grid.size).each do |row_index|
    # start from the left
    col_index = 0
    rocks = 0

    until col_index >= grid.size
      current = grid[row_index][col_index]
      case current
      when 'O'
        grid[row_index][col_index] = '.'
        rocks += 1
      when '.'
      when '#'
        (0...rocks).each do |i|
          grid[row_index][col_index - 1 - i] = 'O'
        end
        rocks = 0
      else
        raise "Unexpected #{current}"
      end
      col_index += 1
    end

    (0...rocks).each do |i|
      grid[row_index][col_index - 1 - i] = 'O'
    end
  end
end

def load(grid)
  grid.map.with_index do |line, row_index|
    line.map do |c|
      c == 'O' ? grid.size - row_index : 0
    end.sum
  end.sum
end

def transpose(grid)
  grid.transpose.map(&:reverse)
end

# tilt_north(grid)
# display_grid(grid)

# puts "part1: #{load(grid)}"

visited = Set.new
visited << grid.map(&:join).join

def cycle(grid)
  tilt_north(grid)
  display_grid(grid)

  tilt_west(grid)
  display_grid(grid)

  tilt_south(grid)
  display_grid(grid)

  tilt_east(grid)
  display_grid(grid)
  grid
end

cycles = 3

cycles.times do |i|
  grid = cycle(grid)

  puts "cycle #{i + 1}" if (i + 1) % 10000 == 0
end

puts "part2: #{load(grid)}"
