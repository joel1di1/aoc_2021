require 'byebug'
require 'set'
require_relative '../../fwk'

TOTAL_MINUTES = 30

class MaxHeap
  def initialize
    @heap = []
  end

  def empty?
    @heap.empty?
  end

  def size
    @heap.length
  end

  def <<(element)
    @heap << element
    bubble_up(@heap.length - 1)
  end

  def pop
    swap(0, @heap.length - 1)
    max = @heap.pop
    bubble_down(0)
    max
  end

  def peek
    @heap[0]
  end

  private

  def bubble_up(index)
    parent_index = parent_index(index)
    return if index == 0 || @heap[parent_index] >= @heap[index]

    swap(index, parent_index)
    bubble_up(parent_index)
  end

  def bubble_down(index)
    left_child_index = left_child_index(index)
    right_child_index = right_child_index(index)
    return if left_child_index >= @heap.length

    if right_child_index >= @heap.length || @heap[left_child_index] >= @heap[right_child_index]
      child_index = left_child_index
    else
      child_index = right_child_index
    end

    return if @heap[index] >= @heap[child_index]

    swap(index, child_index)
    bubble_down(child_index)
  end

  def swap(index1, index2)
    @heap[index1], @heap[index2] = @heap[index2], @heap[index1]
  end

  def parent_index(index)
    (index - 1) / 2
  end

  def left_child_index(index)
    index * 2 + 1
  end

  def right_child_index(index)
    index * 2 + 2
  end
end

class PriorityQueue
  def initialize
    @elements = []
  end

  def push(element, priority)
    @elements << [priority, element]
  end

  def pop
    @elements.sort_by! { |priority, _| priority }
    @elements.shift
  end

  def empty?
    @elements.empty?
  end
end


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

    # debugger if !valid?
  end


  def <=>(other)
    comp = self.potential_rate <=> other.potential_rate 
    return -comp if comp != 0

    comp = self.confirmed_rate <=> other.confirmed_rate
    return -comp if comp != 0

    comp = self.sequence.length <=> other.sequence.length
    return -comp if comp != 0

    Random.rand(-1..1)
  end

  def >=(other)
    (self <=> other) >= 0
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
              sequence: @sequence + ["#{last}"],
              remaining_steps: @remaining_steps - 1,
              confirmed_rate: @confirmed_rate + (last.rate * (@remaining_steps-1)))
  end

  def to_s
    "Path: - remaining_steps: #{remaining_steps} - confirmed_rate: #{confirmed_rate} - potential_rate: #{potential_rate}"\
    "\nme(#{sequence.length})\t#{sequence}"\
  end

  def inspect
    to_s
  end

  def valid?
    current_rate = 0
    total_pressure = 0
    (0..TOTAL_MINUTES).each do |i|
      total_pressure += current_rate
      if sequence[i]&.instance_of?(String)
        current_rate += sequence[i-1].rate
      end
    end

    total_pressure == confirmed_rate
  end

  def potential_rate
    @potential_rate ||= @confirmed_rate + max_remaining_rate
  end

  def max_remaining_rate
    sorted_rate = @closed_valves.map(&:rate).sort.reverse
    remaining_rate = 0
    local_remaining_steps = remaining_steps

    distance_min_me = distance_to_nearest_closed_valve(last)

    i = local_remaining_steps - distance_min_me
    while i > 0
      # I take the first rate
      remaining_rate += (sorted_rate.shift || 0) * (i-1)
      i -= 2
    end

    remaining_rate
  end

  def valid_total_rate
    current_rate = 0
    total_pressure = 0
    puts "Minutes\tValve\tRate\tTotal\tNew_rate"
    (0..TOTAL_MINUTES).each do |i|
      valve = sequence[i]
      total_pressure += current_rate
      print "#{i}\t#{valve}\t#{current_rate}\t#{total_pressure}\t"
      if valve&.instance_of?(String)
        current_rate += sequence[i-1].rate
        print "#{sequence[i-1].rate}"
      end
      puts
    end

    puts "Total pressure: #{total_pressure} - confirmed_rate: #{confirmed_rate} - #{total_pressure == confirmed_rate ? 'OK' : 'KO'}"
  end

  def next_paths()
    tmp = [] 
    # add paths open valve if not already open
    if self.last_closed?
      tmp << self.open_last
    end
    # add moving paths
    # all valves that would lead to useless cycles are removed
    tmp_index = sequence.length - 1
    last_valve = sequence[tmp_index]
    useless_valves = Set.new
    loop do
      break if last_valve.instance_of?(String)
      useless_valves << last_valve
      tmp_index -= 1
      break if tmp_index < 0
      last_valve = sequence[tmp_index]
    end

    self.last.neighbors.reject{|n| useless_valves.include?(n) }.each do |neighbor|
      tmp << self.move_to(neighbor)
    end

    tmp.select{|path| path.potential_rate > $best_path.confirmed_rate }
  end

  def distance_to_nearest_closed_valve(start_valve)
    # Create a set to store the valves that have been visited
    visited = Set.new
  
    # Create a priority queue to store the valves that need to be processed
    # The priority queue will be sorted by the distance from the start valve
    pq = PriorityQueue.new
  
    # Add the start valve to the priority queue with a distance of 0
    pq.push(start_valve, 0)
  
    # While there are valves in the priority queue
    while !pq.empty?
      # Get the valve with the smallest distance from the priority queue
      distance, current_valve = pq.pop
  
      # If the current valve has a non-nil value, return it
      return distance if @closed_valves.include?(current_valve)
  
      # Mark the current valve as visited
      visited.add(current_valve)
  
      # For each neighbor of the current valve
      current_valve.neighbors.each do |neighbor|
        # If the neighbor has not been visited
        if !visited.include?(neighbor)
          # Calculate the distance to the neighbor as the distance to the current valve + 1
          neighbor_distance = distance + 1
  
          # Add the neighbor to the priority queue with the calculated distance
          pq.push(neighbor, neighbor_distance)
        end
      end
    end
  
    # If no valve was found, return 0
    0
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

# marked valves with rate 0 as closed
closed_valves = valves.values.select{|v| v.rate > 0}.freeze
puts "closed_valves: #{closed_valves.length}"

$best_path = nil

def greedy(closed_valves, valve_aa)
  # greedy algorithm
  current_path = Path.new(closed_valves: closed_valves, sequence: [valve_aa], remaining_steps: TOTAL_MINUTES, confirmed_rate: 0)

  while current_path.remaining_steps > 0
    # move me
    # if current valve is closed, open it
    if current_path.last_closed?
      current_path = current_path.open_last 
    else
      # if current valve is open, move to max rated neighbor
      next_neighbor = current_path.last.neighbors.select { |n| current_path.closed_valves.include?(n) }.sort_by(&:rate).last
      next_neighbor ||= current_path.last.neighbors.sample
      current_path = current_path.move_to(next_neighbor)
    end
  end
  current_path
end


100.times do 
  current_path = greedy(closed_valves, valve_aa)
  $best_path = current_path if $best_path.nil? || current_path.confirmed_rate > $best_path.confirmed_rate
end

puts "greedy: #{$best_path}"
# puts "\tvalidation:"
# $best_path.valid_total_rate

# test potential rate
test_valves = [Valve.new('A', 10), Valve.new('B', 20), Valve.new('C', 30)].map{|v| [v.name, v]}.to_h
assert_eq 56, Path.new(closed_valves: [test_valves['B']], sequence: [test_valves['C']], remaining_steps: 0, confirmed_rate: 56).potential_rate
assert_eq 56, Path.new(closed_valves: [test_valves['B']], sequence: [test_valves['C']], remaining_steps: 1, confirmed_rate: 56).potential_rate
assert_eq 76, Path.new(closed_valves: [test_valves['B']], sequence: [test_valves['C']], remaining_steps: 2, confirmed_rate: 56).potential_rate
assert_eq 56, Path.new(closed_valves: [], sequence: [test_valves['C']], remaining_steps: 200, confirmed_rate: 56).potential_rate
assert_eq 20, Path.new(closed_valves: [test_valves['B'], test_valves['A']], sequence: [test_valves['C']], remaining_steps: 2, confirmed_rate: 0).potential_rate
assert_eq 40, Path.new(closed_valves: [test_valves['B'], test_valves['A']], sequence: [test_valves['C']], remaining_steps: 3, confirmed_rate: 0).potential_rate
assert_eq 70, Path.new(closed_valves: [test_valves['B'], test_valves['A']], sequence: [test_valves['C']], remaining_steps: 4, confirmed_rate: 0).potential_rate


mh = MaxHeap
10_000.times do
  mh.push(Random.rand(100))
end

cur = mh.pop
while !mh.empty?
  next_val = mh.pop
  assert cur >= next_val
  cur = next_val
end


# # A* algorithm
paths_to_explore = MaxHeap.new

start = Path.new(closed_valves: closed_valves, sequence: [valve_aa], remaining_steps: TOTAL_MINUTES, confirmed_rate: 0)
paths_to_explore << start

iter = 0
while !paths_to_explore.empty? 
  # paths_to_explore.each do |path|
  #   puts "\t #{path}"
  # end
  
  current_path = paths_to_explore.pop
  if iter % 1_000 == 0
    puts "iter: #{iter}, paths to explore: #{paths_to_explore.size}, $best_path: #{$best_path.confirmed_rate}" 
    puts "-- exploring #{current_path}"
  end
  
  iter+=1
  # if current_path.potential_rate <= $best_path.confirmed_rate
  #   puts "path #{current_path} is not worth exploring"
  #   break
  # end
  
  if current_path.confirmed_rate > $best_path.confirmed_rate
    $best_path = current_path
    # clear paths to explore
    # paths_to_explore = paths_to_explore.select{|p| p.potential_rate > $best_path.confirmed_rate }
  end
    
  # add child paths
  current_path.next_paths.each do |next_path|
    paths_to_explore << next_path
  end
end

puts "best path: #{$best_path}"
puts "\tvalidation:"
$best_path.valid_total_rate
