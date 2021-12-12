# frozen_string_literal: true

require 'readline'
require 'byebug'
require 'set'

def assert_eq(expected, actual)
  raise "Expected #{expected} but received #{actual}" if expected != actual
end

def assert(actual)
  raise "Expected truthy but received #{actual}" unless actual
end

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

  def ends?
    name == 'end'
  end

  def to_s
    name
  end
end

assert_eq 'my_name', Cave.new('my_name').name
assert Cave.new('end').ends?
assert !Cave.new('ab').ends?
assert !Cave.new('ab').big?
assert Cave.new('AB').big?
assert Cave.new('A').big?

class Path
  def initialize(*caves, joker_used: false)
    @caves = caves.flatten.freeze
    @joker_used = joker_used
  end

  def self_and_next_paths
    return [self] if @caves.last.ends?

    [self] + next_paths
  end

  def next_paths
    neighbors = @caves.last.neighbors
    next_paths = neighbors.map do |next_cave|
      if can_go_into?(next_cave)
        Path.new(@caves.to_a + [next_cave], joker_used: @joker_used)
      elsif !@joker_used && next_cave.name != 'start'
        Path.new(@caves.to_a + [next_cave], joker_used: true)
      end
    end
    next_paths.compact!
    next_paths.map(&:self_and_next_paths).flatten
  end

  def to_s
    @caves.map(&:to_s).join(',')
  end

  def ==(other)
    other.caves == caves
  end

  def ends?
    @caves.last.ends?
  end

  def can_go_into?(cave)
    return true if cave.big?
    return false if cave.name == 'start'

    !@caves.include?(cave)
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

caves = read_caves(<<~TEXT)
  start-A
  A-end
TEXT

p = Path.new(caves['start'], caves['A'], caves['end'])
assert p.ends?
assert_eq [p], p.self_and_next_paths

puts Path.new(caves['start']).self_and_next_paths
assert_eq [p], p.self_and_next_paths

p = Path.new(caves['start'], caves['A'])
assert !p.can_go_into?(caves['start'])
assert_eq 2, p.self_and_next_paths.count
assert_eq 3, Path.new(caves['start']).self_and_next_paths.count

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
