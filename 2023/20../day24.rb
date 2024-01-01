# frozen_string_literal: true

require 'colorize'
require 'readline'
require 'byebug'
require 'set'
require_relative '../../fwk'

class Hail
	attr_reader :px, :py, :pz, :vx, :vy, :vz, :a, :b

	def initialize(line)
    left, right = line.split(' @ ')
    @px, @py, @pz = left.split(',').map(&:to_i)
    @vx, @vy, @vz = right.split(',').map(&:to_i)

    x10 = px + vx
    y10 = py + vy

    @a = (y10 - py).to_f / (x10 - px)
    @b = py - a * px
	end

  def to_s
    "pos=<x=#{px}, y=#{py}, z=#{pz}>, vel=<x=#{vx}, y=#{vy}, z=#{vz}>"
  end

  def inspect
    to_s
  end

  def intersection_xy_with(other)
    x = (other.b - b) / (a - other.a)
    y = a * x + b

    time_x = (x - px) / vx
    time_other_x = (x - other.px) / other.vx

    [x, y, time_x, time_other_x]
  end
end

lines = File.readlines('input24.txt', chomp: true)

hails = lines.map do |line|
  Hail.new(line)
end

# puts hails[0].intersection_xy_with(hails[1]).inspect
# puts hails[0].intersection_xy_with(hails[2]).inspect
# puts hails[1].intersection_xy_with(hails[2]).inspect

# puts 

test_range = (200000000000000..400000000000000)

# all combinaisons of 2 hails
in_range = hails.combination(2).map do |h1, h2|
  inter = h1.intersection_xy_with(h2)
  # puts "#{h1}, #{h2} #{inter.inspect}"
  inter
end.select do |x, y, time_x, time_y|
  test_range.include?(x) && test_range.include?(y) && time_x > 0 && time_y > 0
end

# puts "in_range: #{in_range}"
puts "Part1: #{in_range.size}"


# Part 2
# k_stone : 
# k_x = k_px + k_vx * time
# k_y = k_py + k_vy * time
# k_z = k_pz + k_vz * time

# k_stone collide with s1 :
# s1_x = s1_px + s1_vx * time
# s1_y = s1_py + s1_vy * time
# s1_z = s1_pz + s1_vz * time

# k_stone collide with s2 :
# s2_x = s2_px + s2_vx * time
# s2_y = s2_py + s2_vy * time
# s2_z = s2_pz + s2_vz * time

# k_stone collide with s3 :
# s3_x = s3_px + s3_vx * time
# s3_y = s3_py + s3_vy * time
# s3_z = s3_pz + s3_vz * time


# k_x = k_px + k_vx * time
# s1_x = s1_px + s1_vx * time
# s2_x = s2_px + s2_vx * time
# s3_x = s3_px + s3_vx * time

(s1_x - s1_px)/s1_vx = (k_x - k_px)/k_vx
