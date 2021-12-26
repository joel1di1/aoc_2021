# frozen_string_literal: true

require_relative '../../fwk'

def display(grid, msg = '')
  puts ''
  puts msg
  puts grid.map(&:join).join("\n")
end

def step(grid)
  new_grid = grid.map { |l| l.map { |c| c } }
  Array.new(grid.size) { Array.new(grid.first.size, '.') }
  (0..grid.size - 1).each do |i|
    (0..grid.first.size - 1).each do |j|
      if grid[i][j] == '>' && grid[i][(j + 1) % grid.first.size] == '.'
        new_grid[i][j] = '.'
        new_grid[i][(j + 1) % grid.first.size] = '>'
      end
    end
  end

  # display(new_grid, 'half step')

  grid = new_grid
  new_grid = grid.map { |l| l.map { |c| c } }
  (0..grid.size - 1).each do |i|
    (0..grid.first.size - 1).each do |j|
      if grid[i][j] == 'v' && grid[(i + 1) % grid.size][j] == '.'
        new_grid[i][j] = '.'
        new_grid[(i + 1) % grid.size][j] = 'v'
      end
    end
  end
  new_grid
end

def find_stop(file)
  previous_grid = [[]]
  grid = File.readlines(file).map { |line| line.strip.chars }

  display(grid, 'init')
  step = 0
  until grid == previous_grid
    step += 1
    previous_grid = grid
    grid = step(grid)
    # display(grid, "step #{step}")
  end

  puts "#{step} steps for #{file}"
end

find_stop('day25_sample.txt')
find_stop('day25.txt')