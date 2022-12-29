# frozen_string_literal: true

require_relative '../../fwk'

class SquareShape
  attr_reader :dimensions

  def initialize(dimensions)
    @dimensions = dimensions.freeze
  end

  # return array of SquareShape objects
  # as the result of the substraction of the current shape with the other shape
  # the result will cover the same area as the current shape + the other shape
  # but with no overlapping
  def -(other)
    # if other covers entirely the current shape, return an empty array
    return [] if dimensions.all? do |dim, range|
      other.dimensions[dim].min <= range.min && other.dimensions[dim].max >= range.max
    end

    # if other does not covers the current shape, return shape
    return [self] if dimensions.any? do |dim, range|
      other.dimensions[dim].max < range.min || other.dimensions[dim].min > range.max
    end

    shapes = []

    dimensions.each do |dim, range|
      # if other covers the left part of the range, split the range in two 
      # add a new shape with the right part
      # and recursively substract the other shape from the left part
      if range.min <= other.dimensions[dim].max && other.dimensions[dim].max < range.max
        new_dimensions = dimensions.dup
        new_dimensions[dim] = (other.dimensions[dim].max + 1..range.max)
        shapes << SquareShape.new(new_dimensions)
        new_dimensions = dimensions.dup
        new_dimensions[dim] = (range.min..other.dimensions[dim].max)
        return (shapes + (SquareShape.new(new_dimensions) - other)).compact
      end
      
      # same for the right part
      if range.min < other.dimensions[dim].min  && other.dimensions[dim].min <= range.max
        new_dimensions = dimensions.dup
        new_dimensions[dim] = (range.min..other.dimensions[dim].min - 1)
        shapes << SquareShape.new(new_dimensions)
        new_dimensions = dimensions.dup
        new_dimensions[dim] = (other.dimensions[dim].min..range.max)
        return (shapes + (SquareShape.new(new_dimensions) - other)).compact
      end
    end

    shapes
  end

  def volume
    dimensions.values.map { |range| range.max - range.min + 1 }.reduce(:*)
  end
end

def assert_subs(dim_a, dim_b, dim_expected)
  sa = SquareShape.new(dim_a)
  sb = SquareShape.new(dim_b)
  assert_eq dim_expected, (sa - sb).map(&:dimensions)
end

def tests
  assert_subs({x: 1..10}, {x: 5..15}, [{x: 1..4}])
  assert_subs({x: 1..1}, {x: 1..1}, [])
  assert_subs({x: 1..10}, {x: -1..20}, [])
  assert_subs({x: -5..5}, {x: 1..5}, [{x: -5..0}])
  assert_subs({x: 2..2}, {x: 1..1}, [{x: 2..2}])
  assert_subs({x: 1..5, y: 1..5}, {x: 4..7, y: 3..7}, [{:x=>1..3, :y=>1..5}, {:x=>4..5, :y=>1..2}])
  assert_subs({x: 11..13, y: 11..13}, {x: 10..12, y: 10..12}, [{:x=>13..13, :y=>11..13}, {:x=>11..12, :y=>13..13}])
  assert_subs({x: 1..5, y: 1..5, z: 1..5}, {x: 3..7, y: 3..7, z: 3..7}, [{:x=>1..2, :y=>1..5, :z=>1..5}, {:x=>3..5, :y=>1..2, :z=>1..5}, {:x=>3..5, :y=>3..5, :z=>1..2}])

  assert_eq 100, SquareShape.new({x: 1..10, y: 1..10}).volume
  puts "Test OK!"
end

tests

def off(x:, y:, z:)
  @shapes_on.each do |shape|
    new_shapes = shape - SquareShape.new({x: x, y: y, z: z})
    @shapes_on -= [shape]
    @shapes_on += new_shapes
  end
  @shapes_on.compact!
end

def on(x:, y:, z:)
  new_shapes = [SquareShape.new({x: x, y: y, z: z})]
  @shapes_on.each do |shape|
    new_shapes = new_shapes.flat_map { |new_shape| new_shape - shape }
  end
  @shapes_on += new_shapes.compact
end

def process(file)
  @shapes_on = []
  cmds = File.readlines(file).map do |l|  
    l.strip.gsub('=', ':')
  end

  cmds.each do |cmd| 
    eval cmd 
  end

  puts "total lit #{file}: #{@shapes_on.map(&:volume).sum}"
end

process('day22_small_sample.txt')
process('day22_sample.txt')
process('day22.txt')
