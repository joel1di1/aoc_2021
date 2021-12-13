# frozen_string_literal: true

require_relative '../../fwk'

class Universe
  def initialize(*cubes)
    clear
    cubes.each { |cube| @matrix[cube.coords] = cube }
  end

  def at(coords, active: false, create: false)
    cube = @matrix[coords]
    return cube if cube

    @matrix[coords] = Cube.new(coords, active: active) if create
  end

  def clear
    @matrix = {}
  end

  def expand!
    @matrix.values.map { |cube| cube.neighbors(create: true) }
  end

  def cycle
    expand!
    next_active_cubes = @matrix.values.map do |cube|
      active_neighbors = cube.neighbors.select(&:active?).count
      cube if (cube.active? && active_neighbors in 2..3) || (!cube.active? && active_neighbors == 3)
    end.compact!

    @matrix.values.map(&:deactivate!)
    next_active_cubes.map(&:activate!)
  end

  def cubes
    @matrix.values
  end
end

UNIVERSE = Universe.new

class Cube
  attr_reader :coords

  def initialize(coords, active: false)
    @coords = coords.freeze
    @active = active
  end

  def neighbors(create: false)
    (-1..1).map do |x|
      (-1..1).map do |y|
        (-1..1).map do |z|
          (-1..1).map do |w|
            n_coords = { x: @coords[:x] + x, y: @coords[:y] + y, z: @coords[:z] + z, w: @coords[:w] + w }
            UNIVERSE.at(n_coords, create: create) if n_coords != coords
          end
        end
      end
    end.flatten.compact
  end

  def ==(other)
    coords == other.coords
  end

  def <=>(other)
    coords.to_s <=> other.coords.to_s
  end

  def to_s
    "#{coords.to_s} | #{@active}"
  end

  def activate!
    @active = true
  end

  def active?
    @active
  end

  def deactivate!
    @active = false
  end
end

def process(file)
  UNIVERSE.clear
  File.readlines(file).map.with_index do |line, x|
    line.strip.chars.each_with_index do |c, y|
      UNIVERSE.at({ x: x, y: y, z: 0, w: 0 }, active: c == '#', create: true)
    end
  end

  6.times { UNIVERSE.cycle }
  puts UNIVERSE.cubes.select(&:active?).count
end

process('day17_sample.txt')
process('day17.txt')