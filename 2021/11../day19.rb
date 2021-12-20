# frozen_string_literal: true

require_relative '../../fwk'

class Scan
  def initialize

  end
end

class Point
  attr_reader :x, :y, :z

  def initialize(x, y, z)
    @x = x
    @y = y
    @z = z
  end

  def to_s
    "(#{x}, #{y}, #{z})"
  end

  def distance_to(other)
    Math.sqrt((x - other.x).pow(2) + (y - other.y).pow(2) + (z - other.z).pow(2))
  end
end

def read_inputs(file)
  scans = []
  lines = File.readlines(file).map(&:strip)
  scan = nil
  until lines.empty?
    line = lines.shift
    case line
    when /scanner/
      scan = []
      scans << scan
    when /(-?\d+),(-?\d+),(-?\d+)/
      scan << Point.new(Regexp.last_match[1].to_i, Regexp.last_match[2].to_i, Regexp.last_match[3].to_i)
    end
  end
  puts scans
end

read_inputs('day19.txt')

