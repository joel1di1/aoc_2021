# frozen_string_literal: true

require 'colorize'
require 'readline'
require 'byebug'
require 'set'
require_relative '../../fwk'

class Bag
  attr_accessor :target_coords, :coords, :next_bags, :count

  def initialize
    @count = 0
    @next_bags = []
    @target_coords = []
  end

  def inc
    @count += 1
  end

  def pass!
    (0...@count).each do |i|
      @next_bags[i].inc
    end
    @count = 0
  end

  def to_s
    "#{@target_coords} #{@count}"
  end

  def inspect
    to_s
  end
end

def print_grid(grid, grid_of_bags)
  # puts ((0...grid.size).map do |i|
  #   (0...grid[i].size).map do |j|
  #     bag = grid_of_bags[[i, j]]
  #     if bag.nil?
  #       '#'
  #     elsif bag.target_coords.index([i, j]) < bag.count
  #       'O'
  #     else
  #       '.'
  #     end
  #   end.join
  # end.join("\n"))

  # puts
end

def load(grid, grid_of_bags)
  (0...grid.size).map do |i|
    (0...grid[i].size).map do |j|
      bag = grid_of_bags[[i, j]]
      if bag.nil?
        0
      elsif bag.target_coords.index([i, j]) < bag.count
        grid.size - i
      else
        0
      end
    end.sum
  end.sum
end

grid = File.readlines("#{__dir__}/input14.txt", chomp: true).map(&:chars)

grid_of_bags_north = {}
grid_of_bags_south = {}
grid_of_bags_east = {}
grid_of_bags_west = {}

(0...grid.size).each do |i|
  north_bag = Bag.new
  south_bag = Bag.new

  (0...grid[i].size).each do |j|
    char = grid[i][j]
    case char
    when '.', 'O'
      grid_of_bags_north[[i, j]] = north_bag
      grid_of_bags_south[[i, j]] = south_bag

      north_bag.target_coords << [i, j]
      south_bag.target_coords.insert(0, [i, j])
    when '#'
      north_bag = Bag.new
      south_bag = Bag.new
    else
      raise "Unknown char #{char}"
    end
  end
end

(0...grid[0].size).each do |j|
  west_bag = Bag.new
  east_bag = Bag.new

  (0...grid.size).each do |i|
    char = grid[i][j]
    case char
    when '.', 'O'
      grid_of_bags_west[[i, j]] = west_bag
      grid_of_bags_east[[i, j]] = east_bag

      west_bag.target_coords.insert(0, [i, j])
      east_bag.target_coords << [i, j]
    when '#'
      west_bag = Bag.new
      east_bag = Bag.new
    else
      raise "Unknown char #{char}"
    end
  end
end

(0...grid.size).each do |i|
  (0...grid[i].size).each do |j|
    char = grid[i][j]
    next if char == '#'

    north = grid_of_bags_north[[i, j]]
    south = grid_of_bags_south[[i, j]]
    west = grid_of_bags_west[[i, j]]
    east = grid_of_bags_east[[i, j]]

    north.next_bags << west
    west.next_bags.insert(0, south)
    south.next_bags.insert(0, east)
    east.next_bags << north

    next if char == '.'

    east.inc
  end
end


norths = grid_of_bags_north.values
wests = grid_of_bags_west.values
souths = grid_of_bags_south.values
easts = grid_of_bags_east.values

print_grid(grid, grid_of_bags_east)
puts "part 1: #{load(grid, grid_of_bags_east)}"

1_000_000_000.times do |i|

  puts i if i % 10000 == 0
  souths.each(&:pass!)
  # print_grid(grid, grid_of_bags_east)
  easts.each(&:pass!)
  # print_grid(grid, grid_of_bags_north)
  norths.each(&:pass!)
  # print_grid(grid, grid_of_bags_west)
  wests.each(&:pass!)
  # print_grid(grid, grid_of_bags_south)
end

puts "part 2: #{load(grid, grid_of_bags_south)}"
