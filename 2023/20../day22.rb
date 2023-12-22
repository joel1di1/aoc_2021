# frozen_string_literal: true

require 'colorize'
require 'readline'
require 'byebug'
require 'set'
require_relative '../../fwk'

class Brick
	attr_reader :upper_bricks, :lower_bricks, :name, :min_x, :max_x, :min_y, :max_y, :min_z, :max_z

	def initialize(name, str)
		@name = name

		left, right = str.split('~').map do |coords_str|
			coords_str.split(',').map(&:to_i)
		end

		@upper_bricks = Set.new
		@lower_bricks = Set.new
		@min_x = [left[0], right[0]].min
		@max_x = [left[0], right[0]].max
		@min_y = [left[1], right[1]].min
		@max_y = [left[1], right[1]].max
		@min_z = [left[2], right[2]].min
		@max_z = [left[2], right[2]].max
	end

	def add_upper_brick(brick)
		@upper_bricks << brick
	end

	def add_lower_brick(brick)
		@lower_bricks << brick
	end

	def to_s
		"#{name}: #{min_x},#{min_y},#{min_z} - #{max_x},#{max_y},#{max_z}"
	end

	def inspect
		to_s
	end

	def down!
		@min_z -= 1
		@max_z -= 1
	end

  def clear_links
    @upper_bricks.clear
    @lower_bricks.clear
  end

  def other_bricks_that_would_fall
    @up_brick_that_would_fall ||= upper_bricks.select { |up_brick| up_brick.lower_bricks.size <= 1 }
    @up_brick_that_would_fall + @up_brick_that_would_fall.map(&:other_bricks_that_would_fall).flatten
  end
end

def link_to(brick, bricks_by_xy)
	brick.min_x.upto(brick.max_x) do |x|
		brick.min_y.upto(brick.max_y) do |y|
			bricks_by_xy[[x, y]].each do |other_brick|
				next if other_brick == brick

				if other_brick.max_z == brick.min_z - 1
					brick.add_lower_brick(other_brick)
					other_brick.add_upper_brick(brick)
				end
			end
		end
	end
end

def clear_links
	@upper_bricks.clear
	@lower_bricks.clear
end

def relink_bricks(bricks, bricks_by_xy)
	bricks.each(&:clear_links)
	bricks.each do |brick|
		link_to(brick, bricks_by_xy)
	end
end

bricks = []

File.readlines('input22.txt', chomp: true).map.with_index do |line, i|
	# get name from i
	# i is 0, 1, 2, ... and name should be A, B, C, ...
	bricks << Brick.new(i, line)
end

bricks_by_xy = {}

bricks.each do |brick|
	brick.min_x.upto(brick.max_x) do |x|
		brick.min_y.upto(brick.max_y) do |y|
			bricks_by_xy[[x, y]] ||= []
			bricks_by_xy[[x, y]] << brick
		end
	end
end

relink_bricks(bricks, bricks_by_xy)

bricks_without_lower = bricks.select { |b| b.min_z > 1 }.select { |b| b.lower_bricks.empty? }

until bricks_without_lower.empty?
	bricks_without_lower.each do |brick|
		brick.down!
	end
  relink_bricks(bricks, bricks_by_xy)

	bricks_without_lower = bricks.select { |b| b.min_z > 1 }.select { |b| b.lower_bricks.empty? }
end

puts bricks

bricks_can_move = bricks.select do |brick|
  brick.upper_bricks.empty? || brick.upper_bricks.all? {|up_brick| up_brick.lower_bricks.size > 1 }
end

puts "Part 1: #{bricks_can_move.size}"

puts "Part 2: #{bricks.map(&:other_bricks_that_would_fall).flatten.compact.size}"