# frozen_string_literal: true

require 'readline'
require 'byebug'
require 'set'
require_relative '../../fwk'

lines = File.readlines("#{__dir__}/input8.txt", chomp: true)

SEQUENCE = lines.first

lines.shift
lines.shift

NODES = lines.map do |line|
  match = /(\w{3}) = \((\w{3}), (\w{3})\)/.match(line)
  name = match[1]
  left = match[2]
  right = match[3]

  [name, [left, right]]
end.to_h.freeze

class Ghost
  attr_reader :name, :path, :visited, :loop, :finishing_nodes, :first_finishing_index, :loop_size, :shift_for_loop

  def initialize(name)
    @name = name
    @path = []
    @path << [name, 0]
    @visited = {}
    @visited[[name, 0]] = 0
    @loop = false
    @shift_for_loop = 0
  end

  def next(step)
    mod = (step-1) % SEQUENCE.size
    dir = SEQUENCE[mod]
    next_node = NODES[@path.last[0]][dir == 'L' ? 0 : 1]

    # puts "#{name} at step #{step} (#{dir}) goes from #{@path[-1].first} (#{NODES[@path.last[0]]}) to #{next_node}"

    puts "#{name} found Z at step #{step}" if next_node.end_with?('Z')

    visited_index = @visited[[next_node, mod]]
    if visited_index
      @loop = true

      @shift_for_loop = visited_index
      finisher_index = @path.index(@path.select { |p| p[0].end_with?('Z') }.first)
      # puts "#{@path.select { |p| p[0].end_with?('Z') }.first}, finisher_index: #{finisher_index}, path: #{@path}"

      # find the node where the loop starts
      @path = @path[visited_index..]
      # in that new path, find the node with a name that ends with Z
      @finishing_nodes = @path.select { |p| p[0].end_with?('Z') }

      @loop_size = @path.size

      # puts "loop detected for ghost #{name}: #{[next_node, mod]}, loop start index: #{visited_index}, loop size: #{path.size}, loop starting at #{path.first}, ending at #{path.last}, loop: #{@path}"
      # puts "\t finisher index: #{finisher_index}"
      # puts "\t finishing nodes: #{finishing_nodes}"

      @first_finishing_index = @path.index(@finishing_nodes.first) + step
      # puts "\t first finishing index: #{first_finishing_index}"
    else
      @path << [next_node, mod]
      @visited[[next_node, mod]] = @path.size - 1
    end
  end

  def next_force(step)
    mod = (step-1) % SEQUENCE.size
    dir = SEQUENCE[mod]
    next_node = NODES[@path.last[0]][dir == 'L' ? 0 : 1]

    puts "#{name} at step #{step} finishes at #{next_node}" if next_node.end_with?('Z')

    # puts "#{name} at step #{step} goes to #{next_node}"

    # puts "#{name} found Z at step #{step}" if next_node.end_with?('Z')

    @path << [next_node, mod]
  end

  def to_s
    "#{name}(loop_size: #{loop_size}, shift_for_loop: #{shift_for_loop})"
  end

  def looped?
    @loop
  end

  def winning?(steps)
    # puts "\t #{name} steps - @shift_for_loop: #{@shift_for_loop}, loop_size: #{@loop_size}, mod: #{(steps) % @loop_size}"
    steps - 1 % @loop_size == 0
  end
end

starting_positions = NODES.keys.select { |k| k.end_with?('A') }

set = Set.new

ghosts = starting_positions.map { |p| Ghost.new(p) }

puts "starting ghost: #{ghosts.map(&:to_s).join(', ')}"

steps = 0

until ghosts.all?(&:looped?)
  steps += 1

  ghosts.reject(&:looped?).each do |ghost|
    ghost.next(steps)
  end
end

puts ghosts.map(&:loop_size).reduce(1, :lcm)
