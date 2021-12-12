# frozen_string_literal: true

require_relative '../../fwk.rb'

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

  def ending_paths
    return [self] if ends?

    neighbors = @caves.last.neighbors
    next_paths = neighbors.map do |next_cave|
      if can_go_into?(next_cave)
        Path.new(@caves.to_a + [next_cave], joker_used: @joker_used)
      elsif !@joker_used && next_cave.name != 'start'
        Path.new(@caves.to_a + [next_cave], joker_used: true)
      end
    end
    next_paths.compact!
    next_paths.map(&:ending_paths).flatten
  end

  def to_s
    @to_s ||= @caves.map(&:to_s).join(',')
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

def process(input)
  all_caves = read_caves(input)

  paths = Path.new(all_caves['start']).ending_paths

  paths = paths.map(&:to_s).sort
  paths.each { |p| puts p }
  puts "count: #{paths.count}"
end

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
