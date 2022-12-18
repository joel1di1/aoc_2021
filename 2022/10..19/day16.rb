require 'byebug'
require 'set'

TOTAL_MINUTES = 30

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
end

class Path 
  attr_reader :closed_valves, :sequence, :remaining_steps, :confirmed_rate

  def initialize(closed_valves:, sequence:, remaining_steps: TOTAL_MINUTES, confirmed_rate:)
    @sequence = sequence
    @closed_valves = closed_valves
    @remaining_steps = remaining_steps
    @confirmed_rate = confirmed_rate
  end

  def potential_rate
    @confirmed_rate + max_remaining_rate
  end

  def max_remaining_rate
    sorted_rate = @closed_valves.map(&:rate).sort.reverse
    remaining_rate = 0
    local_remaining_steps = remaining_steps

    i = local_remaining_steps
    while i > 1
      remaining_rate += (sorted_rate[local_remaining_steps - i] * (i-1)) if sorted_rate[local_remaining_steps - i]
      i -= 2
    end
    
    remaining_rate
  end

  def <=>(other)
    potential = other.potential_rate <=> self.potential_rate 
    return potential if potential != 0
    
    other.sequence.to_s <=> self.sequence.to_s
  end

  def last
    @last ||= (@sequence[-1].instance_of?(String) ? @sequence[-2] : @sequence[-1])
  end

  def last_closed?
    @closed_valves.include?(last)
  end

  def move_to(neighbor)
    Path.new(closed_valves: @closed_valves, 
             sequence: @sequence + [neighbor], 
             remaining_steps: @remaining_steps - 1, 
             confirmed_rate: @confirmed_rate)
  end

  def open_last
    Path.new(closed_valves: @closed_valves - [last],
              sequence: @sequence + ["open #{last}"],
              remaining_steps: @remaining_steps - 1,
              confirmed_rate: @confirmed_rate + (last.rate * (@remaining_steps-1)))
  end

  def to_s
    "Path: #{sequence} - remaining_steps: #{remaining_steps} - confirmed_rate: #{confirmed_rate} - potential_rate: #{potential_rate}"
  end

  def inspect
    to_s
  end

  def valid_total_rate
    current_rate = 0
    total_pressure = 0
    sequence.each_with_index.map do |valve, i|
      print "Minutes #{i}\t#{valve}\t"
      total_pressure += current_rate
      print "\tcurrent_rate\t#{current_rate}\ttotal_pressure\t#{total_pressure}\t"
      if valve.instance_of?(String)
        current_rate += sequence[i-1].rate
        print(sequence[i-1].rate)
      else
        print(0)
      end
      print "\n"
    end

    puts "Total pressure: #{total_pressure} - confirmed_rate: #{confirmed_rate} - #{total_pressure == confirmed_rate ? 'OK' : 'KO'}"
  end
end

def init_valves 
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

valves = init_valves
valve_aa = valves['AA']

# greedy algorithm
current_path = Path.new(closed_valves: valves.values - [valve_aa], sequence: [valve_aa], remaining_steps: TOTAL_MINUTES, confirmed_rate: 0)

while current_path.remaining_steps > 0
  # move to max rate neighbor
  closed_neighbors = current_path.last.neighbors.select { |n| current_path.closed_valves.include?(n) }
  next_neighbor = closed_neighbors.sort_by(&:rate).last

  # if no closed neighbor, move to sample neighbor
  if next_neighbor.nil?
    next_neighbor = current_path.last.neighbors.sample 
    current_path = current_path.move_to(next_neighbor)
  else
    # if closed neighbor, move to it and open it
    current_path = current_path.move_to(next_neighbor)
    current_path = current_path.open_last if current_path.remaining_steps > 0 && current_path.last.rate > 0
  end
end

best_path = current_path
puts "greedy: #{best_path}"
puts "\tvalidation:"
best_path.valid_total_rate

# part 1
paths_to_explore = SortedSet.new

start = Path.new(closed_valves: valves.values - [valve_aa], sequence: [valve_aa], remaining_steps: TOTAL_MINUTES, confirmed_rate: 0)
paths_to_explore << start


while !paths_to_explore.empty? && paths_to_explore.first.potential_rate > best_path.confirmed_rate
  # puts "paths to explore: #{paths_to_explore.size}, best_path: #{best_path}"
  # paths_to_explore.each do |path|
  #   puts "\t #{path}"
  # end

  current_path = paths_to_explore.first
  paths_to_explore.delete(current_path)
  # puts "-- exploring #{current_path}"
  if current_path.remaining_steps == 0 
    # puts "complete path #{current_path}"
    if best_path.nil? || current_path.confirmed_rate > best_path.confirmed_rate
      best_path = current_path
    end
    next
  end

  # add child paths
  # add path open valve if not already openend
  paths_to_explore << current_path.open_last if current_path.last_closed?

  # add paths without valve openend
  current_path.last.neighbors.each do |neighbor|
    paths_to_explore << current_path.move_to(neighbor)
  end
end

puts "best path: #{best_path}"
puts "\tvalidation:"
best_path.valid_total_rate
