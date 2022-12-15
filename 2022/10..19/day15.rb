require 'byebug'
require 'set'

class Beacon
  attr_reader :x, :y

  def initialize(x, y)
    @x = x
    @y = y
  end

  def to_s
    'B'
  end
end

class Sensor
  attr_reader :closest_beacon, :x, :y

  def initialize(x, y, closest_beacon)
    @x = x
    @y = y
    @closest_beacon = closest_beacon
  end

  def to_s
    "S(#{x},#{y})"
  end
end

# display map
def display(map, beacons, sensors)
  puts "\n"
  min_x, max_x = (beacons + sensors).map(&:x).minmax
  min_y, max_y = (beacons + sensors).map(&:y).minmax

  (min_y..max_y).each do |y|
    (min_x..max_x).each do |x|
      element = map[[x, y]]
      if element.instance_of?(Sensor)
        print 'S'
      else  
        print element || '.'
      end
    end
    puts
  end
end

# read input in day15.txt
# each line describe a sensor position and the closest beacon position
# Ex:
# Sensor at x=2389280, y=2368338: closest beacon is at x=2127703, y=2732666
def read_input
  map = {}
  sensors = []
  beacons = []
  File.readlines('day15.txt').map do |line|
    line =~ /Sensor at x=(\d+), y=(\d+): closest beacon is at x=(-?\d+), y=(-?\d+)/
    beacon = Beacon.new($3.to_i, $4.to_i)
    sensor = Sensor.new($1.to_i, $2.to_i, beacon)
    sensors << sensor
    beacons << beacon
    map[[sensor.x, sensor.y]] = sensor
    map[[beacon.x, beacon.y]] = beacon
  end
  [map, sensors, beacons]
end

map, sensors, beacons = read_input

# display(map, sensors, beacons)

y = 2000000

def covered_range(map, sensor, y)
  distance = (sensor.x - sensor.closest_beacon.x).abs + (sensor.y - sensor.closest_beacon.y).abs
  
  return nil unless ((sensor.y - distance)..(sensor.y+distance)).include?(y)

  y_distance = (sensor.y - y).abs
  left = sensor.x - (distance - y_distance)
  right = sensor.x + (distance - y_distance)
  ((left)..(right))
end


ranges = sensors.map do |sensor|
  covered_range(map, sensor, y)
end.compact

ranges.each do |range|
  puts range
end

# min_x = ranges.map(&:min).min
# max_x = ranges.map(&:max).max

# impossibles = ((min_x)..(max_x)).select do |x|
#   ranges.any?{|range| range.include?(x) } && map[[x,y]].nil?
# end
# puts "\n"

# puts "part1: #{impossibles.size}"

# part 2
MIN = 0
MAX = 4000000

class PossibleRow
  attr_reader :x
  def initialize()
    @ranges = []
    @ranges << (MIN..MAX)
  end

  def remove!(range_to_remove)
    return if range_to_remove.nil?

    @ranges = @ranges.map do |range|
      if range_to_remove.cover?(range)
        nil
      elsif range.cover?(range_to_remove)
        [(range.begin..(range_to_remove.begin-1)), ((range_to_remove.end+1)..range.end)]
      elsif range_to_remove.cover?(range.begin)
        ((range_to_remove.end+1)..range.end)
      elsif range_to_remove.cover?(range.end)
        (range.begin..(range_to_remove.begin-1))
      else
        range
      end
    end.flatten.compact.select{|range| range.size > 0}
  end

  def empty?
    @ranges.empty?
  end

  def solution_x
    @ranges.find(&:first)&.first
  end
end

(MIN..MAX).each do |possible_y|
  puts "#{Time.now} y: #{possible_y}" if possible_y % 100000 == 0
  possible_row = PossibleRow.new
  sensors.each do |sensor|
    range = covered_range(map, sensor, possible_y)
    next if range.nil?
    # print "removing #{range} \t"
    possible_row.remove!(range)
    # pp possible_row
  end
  if possible_row.solution_x
    solution_x = possible_row.solution_x
    puts "x: #{solution_x}, y: #{possible_y}"
    puts "part2: #{solution_x*4000000 + possible_y}"
    break
  end
end
