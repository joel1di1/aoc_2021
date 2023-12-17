# frozen_string_literal: true

require 'colorize'
require 'readline'
require 'byebug'
require 'set'
require_relative '../../fwk'

grid = File.readlines("#{__dir__}/input16.txt", chomp: true).map(&:chars)

class Grid

  attr_reader :energized

  def initialize(grid)
    @grid = grid
    @energized = Set.new
  end

  def [](x, y)
    @grid[x][y]
  end

  def x_size
    @grid.size
  end

  def y_size
    @grid[0].size
  end

  def mark_all(beams)
    beams.each do |beam|
      @energized << [beam.x, beam.y]
    end
  end

  def energized_cells
    @energized.reject { |x, y| x < 0 || y < 0 || x >= x_size || y >= y_size }.size
  end
end

class Beam
  attr_reader :x, :y, :grid, :direction

  def initialize(grid, x, y, direction)
    @grid = grid
    @x = x
    @y = y
    @direction = direction
  end

  # rubocop:disable Metrics/CyclomaticComplexity
  def next
    return [] if x < 0 || y < 0 || x >= grid.x_size || y >= grid.y_size

    char = grid[x, y]
    case char
    when '|'
      case direction
      when :right, :left
        [Beam.new(grid, x + 1, y, :down), Beam.new(grid, x - 1, y, :up)]
      when :up
        [Beam.new(grid, x-1, y, :up)]
      when :down
        [Beam.new(grid, x+1, y, :down)]
      else
        raise "Unknown direction: #{direction}"
      end
    when '-'
      case direction
      when :up, :down
        [Beam.new(grid, x, y + 1, :right), Beam.new(grid, x, y - 1, :left)]
      when :right
        [Beam.new(grid, x, y+1, :right)]
      when :left
        [Beam.new(grid, x, y-1, :left)]
      else
        raise "Unknown direction: #{direction}"
      end
    when '/'
      case direction
      when :up
        [Beam.new(grid, x, y + 1, :right)]
      when :down
        [Beam.new(grid, x, y - 1, :left)]
      when :right
        [Beam.new(grid, x - 1, y, :up)]
      when :left
        [Beam.new(grid, x + 1, y, :down)]
      else
        raise "Unknown direction: #{direction}"
      end
    when '\\'
      case direction
      when :up
        [Beam.new(grid, x, y - 1, :left)]
      when :down
        [Beam.new(grid, x, y + 1, :right)]
      when :right
        [Beam.new(grid, x + 1, y, :down)]
      when :left
        [Beam.new(grid, x - 1, y, :up)]
      else
        raise "Unknown direction: #{direction}"
      end
    when '.'
      case direction
      when :up then [Beam.new(grid, x - 1, y, :up)]
      when :down then [Beam.new(grid, x + 1, y, :down)]
      when :right then [Beam.new(grid, x, y + 1, :right)]
      when :left then [Beam.new(grid, x, y - 1, :left)]
      else
        raise "Unknown direction: #{direction}"
      end
    else
      raise "Unknown char: #{char}"
    end
  end

  def to_s
    @to_s ||= "#{x},#{y} #{direction}"
  end

  def inspect
    to_s
  end

  def ==(other)
    to_s == other.to_s
  end

  def eql?(other)
    to_s.eql?(other.to_s)
  end

  def <=>(other)
    to_s <=> other.to_s
  end
end
# rubocop:enable Metrics/CyclomaticComplexity

grid = Grid.new(grid)

beams = []

beams << Beam.new(grid, 0, 0, :right)

all_beams_str = Set.new
all_beams_str << beams.first.to_s
grid.mark_all(beams)

situations = Set.new

def move_all_once(beams)
  beams.map(&:next).flatten
end

def display_grid_with_beams(grid, beams)
  (0...grid.x_size).each do |x|
    (0...grid.y_size).each do |y|
      if beams.any? { |b| b.x == x && b.y == y }
        print grid[x, y].red
      else
        print grid[x, y]
      end
    end
    puts
  end
  puts
end

def display_grid_with_ernergized_beams(grid)
  (0...grid.x_size).each do |x|
    (0...grid.y_size).each do |y|
      if grid.energized.include?([x, y])
        print "#"
      else
        print '.'
      end
    end
    puts
  end
  puts
end

def energized_cells(grid, beams)
  (0...grid.x_size).map do |x|
    (0...grid.y_size).map do |y|
      if beams.any? { |b| b.x == x && b.y == y }
        1
      else
        0
      end
    end
  end.flatten.sum
end

count = 0
until beams.empty?
  puts "Iteration #{count}" if count % 100 == 0

  beams = move_all_once(beams)

  # display_grid_with_beams(grid, beams)

  beams.reject! do |beam|
    all_beams_str.include?(beam.to_s)
  end

  grid.mark_all(beams)

  all_beams_str.merge(beams.map(&:to_s))

  count += 1
end

# display_grid_with_ernergized_beams(grid)

puts "Part 1: #{grid.energized_cells}"
