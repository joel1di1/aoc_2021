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
  attr_reader :name, :path, :visited

  def initialize(name)
    @name = name
    @path = []
    @path << [name, 0]
    @visited = {}
    @visited[[name, 0]] = 0
  end

  def next(step)
    mod = step % SEQUENCE.size
    dir = SEQUENCE[mod]
    next_node = NODES[@path.last[0]][dir == 'L' ? 0 : 1]
    @path << [next_node, mod]
    @visited[[next_node, mod]] = @path.size - 1
  end
end

class Node
  attr_accessor :name, :mod

  def initialize(name, mod)
    @name = name
    @mod = mod
  end

  def <=>(other)
    res = @name <=> other.name
    return res unless res == 0

    @mod <=> other.mod
  end

  def ==(other)
    @name == other.name && @mod == other.mod
  end

  def to_s
    "#{@name}-#{@mod}"
  end
end

positions = NODES.keys.select { |k| k.end_with?('A') }

set = Set.new

puts "starting positions: #{positions}"

travels = positions.map { |p| Set.new([p, 0]) }
loops = {}

steps = 0
until positions.all? { |p| p.end_with?('Z') }
  mod = steps % SEQUENCE.size
  dir = SEQUENCE[mod]

  old_positions = positions
  positions = positions.map.with_index do |position, index|
    if loops[index].nil?
      node_key = [position, mod]
      if travels[index].include?(node_key)
        puts "loop detected for ghost ##{index}: #{node_key} - index: #{steps}"
        loops[index] = true
      else
        travels[index] << node_key
      end
    end

    next_node = dir == 'L' ? NODES[position][0] : NODES[position][1]

    next_node
  end

  puts "#{steps}: mod(#{mod}) #{dir} #{old_positions} => #{positions}" if loops.size == 6

  steps += 1
end

puts "Part2: #{steps}"
