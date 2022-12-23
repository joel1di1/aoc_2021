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
  
  def self.init_valves(file)
    valves = {}
    File.readlines(file).map do |line|
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

  def cost(neighbor)
    1
  end
end

# a path is a sorted list of closed valves to open
# given a network of valves, the valve where to start and a limited time
class Path
  attr_reader :sequence, :remaining_time, :confirmed

  def initialize(map, valves_to_open, sequence, remaining_time, confirmed)
    @map = map
    @sequence = sequence.freeze
    @remaining_time = remaining_time
    @confirmed = confirmed
    @valves_to_open = valves_to_open.freeze
  end

  def to_s
    @sequence.to_s
  end

  def potential
    @potential ||= @confirmed + max_expected_left
  end

  def last
    @last ||= (@sequence[-1].instance_of?(String) ? @sequence[-2] : @sequence[-1])

    debugger if @last.is_a?(String)
    @last
  end

  def max_expected_left
    sorted_rates = @valves_to_open.map(&:rate).sort.reverse

    return 0 if sorted_rates.empty?

    remaining_rate = 0
    local_remaining_time = @remaining_time

    debugger if local_remaining_time.nil? || distance_to_nearest_valve_to_open.nil?
    i = local_remaining_time - distance_to_nearest_valve_to_open

    while i > 0
      # I take the first rate
      remaining_rate += (sorted_rates.shift || 0) * (i-1)
      i -= 2
    end

    remaining_rate
  end

  def distance_to_nearest_valve_to_open
    @valves_to_open.map do |valve|
      @map.distance_between(last, valve)
    end.min
  end

  def next_paths
    @valves_to_open.map do |valve|
      # distance between last valve and the next one
      debugger if last.is_a?(String)
      distance = @map.distance_between(last, valve)
      
      # move to valve and open it
      new_sequence = @sequence.dup
      distance.times { new_sequence << valve }
      new_sequence << valve.name

      new_remaining_time = @remaining_time - (new_sequence.length - @sequence.length)
      
      new_confirmed = @confirmed + valve.rate * new_remaining_time
      Path.new(@map, @valves_to_open - [valve], new_sequence, new_remaining_time, new_confirmed)
    end
  end
end

class Map
  attr_reader :valves

  def initialize(valves)
    @valves = valves
    @cache = {}
  end

  def distance_between(start, target)
    if @cache[[start, target]].nil?
      val = dijkstra(start, target)
      @cache[[start, target]] = val
      @cache[[target, start]] = val
    end

    @cache[[start, target]]
  end
end


class PressureOptimiser
  def initialize(map, closed_valves)
    @map = map
    @closed_valves = closed_valves.freeze
  end

  def self.from_file(file)
    valves = Valve.init_valves(file).freeze
    closed_valves = valves.values.select { |v| v.rate > 0 }.freeze
    
    map = Map.new(valves)
    new(map, closed_valves)
  end

  def best_path_part1(time: 30)
    current_path = Path.new(@map, @closed_valves, [@map.valves['AA']], time, 0)
    pq = PriorityQueue.new

    pq.push(current_path, current_path.potential)

    best_path = current_path
    until pq.empty? 
      current_path, _ = pq.pop

      # puts "\t exploring path: #{current_path}, potential: #{current_path.potential}, confirmed: #{current_path.confirmed}, remaining_time: #{current_path.remaining_time}"

      next if current_path.potential < best_path.confirmed
      next if current_path.remaining_time < 0

      best_path = current_path if current_path.remaining_time >= 0 && current_path.confirmed > best_path.confirmed

      current_path.next_paths.each do |next_path|
        pq.push(next_path, next_path.potential) if next_path.potential > best_path.confirmed
      end
    end

    best_path
  end

  def part2
    total_pos = (1..(@closed_valves.length/2)).to_a.map { |s| @closed_valves.combination(s).count }.sum
    puts "total possible combinations: #{total_pos}"

    # create all possible s way to split the closed valves into 2 groups
    best_value = 0
    iter = 0

    started_at = Time.now

    1.upto(@closed_valves.length/2) do |s|
      @closed_valves.combination(s).each do |group1|
        group2 = @closed_valves - group1
        best_paths = [group1, group2].map do |group|
          PressureOptimiser.new(@map, group).best_path_part1(time: 26)
        end
        sum = best_paths.map(&:confirmed).sum
        best_value = sum if sum > best_value
        if iter % 100 == 0
          best_paths.each { |p| puts "\t #{p}" }
          puts "iter: #{iter}, best_value: #{best_value}, remaining: #{total_pos - iter}"
          puts "elapsed: #{Time.now - started_at}"
          puts "remaining: #{(Time.now - started_at) * (total_pos - iter) / iter}"
        end
        iter += 1
      end
    end

    best_value
  end
end

def tests
  valves = Valve.init_valves('day16_test.txt').freeze
  closed_valves = valves.values.select { |v| v.rate > 0 }.freeze
  map = Map.new(valves)

  assert_eq 0, Path.new(map, closed_valves, [valves['AA']], 0, 0).potential
  assert_eq 0, Path.new(map, closed_valves, [valves['AA'], 'AA'], 0, 0).potential
  assert_eq 0, Path.new(map, closed_valves, [valves['AA']], 2, 0).potential
  assert_eq 0, Path.new(map, closed_valves, [valves['AA'], 'AA'], 2, 0).potential

  assert_eq 22, Path.new(map, closed_valves, [valves['AA']], 3, 0).potential
  assert_eq 22, Path.new(map, closed_valves, [valves['AA'], 'AA'], 3, 0).potential

  assert_eq 0, Path.new(map, closed_valves, [valves['BB']], 1, 0).potential
  assert_eq 13, Path.new(map, closed_valves - [valves['BB']], [valves['BB'], 'BB'], 1, 13).potential
  assert_eq 13, Path.new(map, closed_valves - [valves['BB']], [valves['BB'], 'BB'], 2, 13).potential
  assert_eq 35, Path.new(map, closed_valves - [valves['BB']], [valves['BB'], 'BB'], 3, 13).potential
end

tests

optimizer = PressureOptimiser.from_file('day16_test.txt')
best = optimizer.best_path_part1
puts "best for test: #{best} (#{best.potential})"

best = optimizer.part2
puts "best for test part2: #{best}"


optimizer = PressureOptimiser.from_file('day16.txt')
best = optimizer.best_path_part1
puts "REAL best: #{best} (#{best.potential})"

best = optimizer.part2
puts "REAL best for part2: #{best}"
