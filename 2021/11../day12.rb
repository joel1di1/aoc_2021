# frozen_string_literal: true

require 'readline'
require 'byebug'
require 'set'

class Cave
  attr_reader :name, :neighbors

  def initialize(name)
    @name = name
    @big = name.upcase == name
    @neighbors = Set.new
  end

  def big?
    @big
  end

  def ==(other)
    other.name == name
  end

  def <<(other)
    @neighbors << other
  end

  def end?
    name == 'end'
  end

  def to_s
    name
  end
end

class Path
  def initialize(*caves)
    @caves = caves.flatten.freeze
    self
  end

  def self_and_next_paths
    last_cave = @caves.last
    return [self] if last_cave.end?

    next_paths = last_cave.neighbors.map do |n|
      Path.new(@caves.to_a + [n]) if can_revisit?(n)
    end.compact
    all_next_path = next_paths.map(&:self_and_next_paths).flatten
    [self] + all_next_path
  end

  def to_s
    @caves.map(&:to_s).join(',')
  end

  def ==(other)
    other.caves == caves
  end

  def ends?
    @caves.last.name == 'end'
  end

  private

  def can_revisit?(cave)
    cave.big? || !@caves.include?(cave)
  end
end

def read_caves(input)
  linked_names = input.split("\n").map { |line| line.split('-') }
  caves = linked_names.flatten.uniq.each_with_object({}) { |name, h| h[name] = Cave.new(name) }
  linked_names.each do |name1, name2|
    cave1 = caves[name1]
    cave2 = caves[name2]
    cave1 << cave2
    cave2 << cave1
  end
  caves
end

def process(input)
  all_caves = read_caves(input)

  path = Path.new(all_caves['start'])
  paths = path.self_and_next_paths.flatten
  paths = Set.new(paths).to_a.select(&:ends?)

  paths = paths.map(&:to_s).uniq.sort
  paths.each { |p| puts p }
  puts "count: #{paths.count}"
end

process(<<~TEXT)
  start-A
  start-b
  A-c
  A-b
  b-d
  A-end
  b-end
TEXT

process(<<~TEXT)
  ma-start
  YZ-rv
  MP-rv
  vc-MP
  QD-kj
  rv-kj
  ma-rv
  YZ-zd
  UB-rv
  MP-xe
  start-MP
  zd-end
  ma-UB
  ma-MP
  UB-xe
  end-UB
  ju-MP
  ma-xe
  zd-UB
  start-xe
  YZ-end
TEXT
