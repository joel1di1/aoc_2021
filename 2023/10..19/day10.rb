# frozen_string_literal: true

require 'colorize'
require 'readline'
require 'byebug'
require 'set'
require_relative '../../fwk'

# get the tiles as a matrix of chars
TILE_CHARS = File.readlines("#{__dir__}/input10.txt", chomp: true).map(&:chars)

class Tile
  attr_accessor :i, :j, :char, :prev, :in_direction, :out_direction

  def initialize(i, j, char, in_direction, prev = nil)
    @i = i
    @j = j
    @char = char
    @in_direction = in_direction
    @prev = prev
    @next = nil
    @out_direction =
      case char
      when '|'
        in_direction
      when '-'
        in_direction
      when 'S'
        in_direction
      when '7'
        in_direction == :up ? :left : :down
      when 'F'
        in_direction == :up ? :right : :down
      when 'L'
        in_direction == :down ? :right : :up
      when 'J'
        in_direction == :down ? :left : :up
      else
        raise "unknown char: #{char}"
      end
  end

  attr_writer :next

  def next
    return @next if @next

    ni, nj = nil
    case out_direction
    when :up
      ni = i - 1
      nj = j
    when :down
      ni = i + 1
      nj = j
    when :left
      ni = i
      nj = j - 1
    when :right
      ni = i
      nj = j + 1
    else
      raise "unknown direction: #{out_direction} for tile #{self}"
    end

    @next = Tile.new(ni, nj, TILE_CHARS[ni][nj], out_direction, self)

    # puts "current: #{self.to_s}, next: #{@next.to_s}"

    @next
  end

  def ==(other)
    @i == other.i && @j == other.j
  end

  def to_s
    "[#{i},#{j}] #{char} (#{in_direction} -> #{out_direction})"
  end
end

# find the tile 'S' as the starting point
start_i, start_j = (0..TILE_CHARS.size-1).map do |i|
  (0..TILE_CHARS[i].size-1).map do |j|
    [i, j] if TILE_CHARS[i][j] == 'S'
  end
end.flatten.compact

start = Tile.new(start_i, start_j, 'S', :up)

next_tile = start.next

next_tile = next_tile.next until next_tile == start

next_tile.prev.next = start
start.prev = next_tile.prev


count = 0
current = start
until current.next == start
  current = current.next
  count += 1
end
puts "part1: #{(count+1)/2}"

# part 2
loop_nodes = Set.new
loop_nodes << [start.i, start.j]

inside_nodes = []

current = start.next

until current == start
  loop_nodes << [current.i, current.j]

  inside_nodes << [current.i, current.j - 1] if current.char == '|' && current.in_direction == :up
  inside_nodes << [current.i, current.j + 1] if current.char == '|' && current.in_direction == :down
  inside_nodes << [current.i + 1, current.j] if current.char == '-' && current.in_direction == :left
  inside_nodes << [current.i - 1, current.j] if current.char == '-' && current.in_direction == :right
  if current.char == '7' && current.in_direction == :right
    inside_nodes << [current.i + 1, current.j]
    inside_nodes << [current.i, current.j + 1]
  end
  if current.char == 'F' && current.in_direction == :up
    inside_nodes << [current.i - 1, current.j]
    inside_nodes << [current.i, current.j - 1]
  end
  if current.char == 'L' && current.in_direction == :left
    inside_nodes << [current.i + 1, current.j]
    inside_nodes << [current.i, current.j - 1]
  end
  if current.char == 'J' && current.in_direction == :down
    inside_nodes << [current.i, current.j + 1]
    inside_nodes << [current.i + 1, current.j]
  end

  current = current.next
end

inside_nodes.reject! { |pair| loop_nodes.include?(pair) }

(0...TILE_CHARS.size).map do |i|
  (0...TILE_CHARS[i].size).map do |j|
    if inside_nodes.include?([i, j])
      print 'I'.red
    elsif loop_nodes.include?([i, j])
      print TILE_CHARS[i][j]
    else
      print '.'
    end
  end
  puts
end

visited = Set.new loop_nodes
real_inside_nodes = Set.new

until inside_nodes.empty?
  node_to_inspect = inside_nodes.pop

  next if loop_nodes.include?(node_to_inspect)

  visited << node_to_inspect

  real_inside_nodes << node_to_inspect

  [[-1, 0], [1, 0], [0, -1], [0, 1]].each do |shift_i, shift_j|
    new_node = [node_to_inspect[0] + shift_i, node_to_inspect[1] + shift_j]
    inside_nodes << new_node unless visited.include?(new_node) || loop_nodes.include?(new_node)
  end
end

puts ''

(0...TILE_CHARS.size).map do |i|
  (0...TILE_CHARS[i].size).map do |j|
    if real_inside_nodes.include?([i, j])
      print 'X'.red
    elsif loop_nodes.include?([i, j])
      print TILE_CHARS[i][j]
    else
      print '.'
    end
  end
  puts
end

puts "Part 2: #{real_inside_nodes.size}"
