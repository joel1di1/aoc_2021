require 'byebug'
require 'set'
require_relative '../../fwk'

class Valve
  attr_reader :neighbors, :name
  attr_accessor :rate

  def initialize(name, rate = nil)
    @name = name
    @rate = rate
    @neighbors = []
  end

  def add_neighbor(neighbor)
    @neighbors << neighbor
  end

  def to_s
    @name
  end

  def inspect
    to_s
  end
  
  def self.init_valves 
    valves = {}
    File.readlines('day16.txt').map do |line|
      # exemple of line:
      # Valve XF has flow rate=0; tunnels lead to valves WI, IZ
      line =~ /Valve (\w+) has flow rate=(\d+); tunnels? leads? to valves? (.*)/
      valve = valves[$1] ||= Valve.new($1)
      valve.rate = $2.to_i
  
      # parse neighbors
      $3.split(', ').each do |neighbor_name|
        neighbor = valves[neighbor_name] ||= Valve.new(neighbor_name)
        valve.add_neighbor(neighbor)
      end
    end
    valves
  end
end

# a path is a sorted list of closed valves to open
# given a network of valves, the valve where to start and a limited time
class Path
  def initialize(valves, valves_to_open, sequence, remaining_time, confirmed_relief)
    @valves = valves
    @sequence = sequence
    @remaining_time = remaining_time
    @confirmed_relief = confirmed_relief
    @valves_to_open = valves_to_open
  end

  def to_s
    @sequence.to_s
  end

  def potential
    @potential ||= confirmed_relief + max_expected_left
  end

  def last
    @last ||= (@sequence[-1].instance_of?(String) ? @sequence[-2] : @sequence[-1])
  end

  def max_expected_left
    sorted_rates = @valves_to_open.map(&:rate).sort.reverse

    remaining_rate = 0
    local_remaining_time = remaining_time

    distance_min_me = distance_to_nearest_valve_to_open(last)

    # debugger
    i = local_remaining_steps - distance_min_me

    while i > 0
      # I take the first rate
      remaining_rate += (sorted_rate.shift || 0) * (i-1)
      i -= 2
    end

    remaining_rate

  end
end

class Map
  attr_reader :valves

  def initialize(valves)
    @valves = valves
    @cache = {}
  end

  def distance_between(start, target)
    @cache[[start, target]] ||= dijkstra(start, target)
  end
end


class PressureOptimiser
  def initialize(valves, closed_valves, remaining_time)
    @valves = valves
    @closed_valves = closed_valves
    @remaining_time = remaining_time
  end
end


valves = Valve.init_valves.freeze
closed_valves = valves.values.select { |v| v.rate > 0 }.freeze

map = Map.new(valves)
puts map.distance_between(valves['AA'], valves['CC'])