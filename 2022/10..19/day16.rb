require 'byebug'
require 'set'

TOTAL_MINUTES = 26

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
  attr_reader :closed_valves, :sequence, :sequence_el, :remaining_steps, :confirmed_rate

  def initialize(closed_valves:, sequence:, remaining_steps: TOTAL_MINUTES, confirmed_rate:, sequence_el:)
    @sequence = sequence
    @sequence_el = sequence_el
    @closed_valves = closed_valves
    @remaining_steps = remaining_steps
    @confirmed_rate = confirmed_rate
  end

  def potential_rate
    @potential_rate ||= @confirmed_rate + max_remaining_rate
  end

  def >=(other)
    (self <=> other) >= 0
  end

  def max_remaining_rate
    sorted_rate = @closed_valves.map(&:rate).sort.reverse
    remaining_rate = 0
    local_remaining_steps = remaining_steps

    distance_min_me = distance_to_nearest_closed_valve(last)
    distance_min_el = distance_to_nearest_closed_valve(last_el)

    i = local_remaining_steps - [distance_min_me, distance_min_el].min
    while i > 0
      # I take the first rate
      remaining_rate += (sorted_rate.shift || 0) * (i-1)
      # elephant takes the second rate
      remaining_rate += (sorted_rate.shift || 0) * (i-1)
      i -= 1
    end

    remaining_rate
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

  def last
    @last ||= (@sequence[-1].instance_of?(String) ? @sequence[-2] : @sequence[-1])
  end

  def last_closed?
    @closed_valves.include?(last)
  end

  def last_el
    @last_el ||= (@sequence_el[-1].instance_of?(String) ? @sequence_el[-2] : @sequence_el[-1])
  end

  def last_closed_el?
    @closed_valves.include?(last_el)
  end

  def move_to(neighbor)
    Path.new(closed_valves: @closed_valves, 
             sequence: @sequence + [neighbor], 
             sequence_el: @sequence_el,
             remaining_steps: @remaining_steps - 1, 
             confirmed_rate: @confirmed_rate)
  end

  # move elephant does not consume time 
  def move_el_to(neighbor)
    Path.new(closed_valves: @closed_valves, 
             sequence_el: @sequence_el + [neighbor], 
             sequence: @sequence,
             remaining_steps: @remaining_steps,
             confirmed_rate: @confirmed_rate)
  end

  def open_last
    Path.new(closed_valves: @closed_valves - [last],
              sequence: @sequence + ["open #{last}"],
              sequence_el: @sequence_el,
              remaining_steps: @remaining_steps - 1,
              confirmed_rate: @confirmed_rate + (last.rate * (@remaining_steps-1)))
  end

  # open elephant does not consume time
  def open_last_el
    Path.new(closed_valves: @closed_valves - [last_el],
      sequence: @sequence,
      sequence_el: @sequence_el + ["open #{last_el}"],
      remaining_steps: @remaining_steps,
      confirmed_rate: @confirmed_rate + (last_el.rate * (@remaining_steps)))
  end

  def to_s
    "Path: - remaining_steps: #{remaining_steps} - confirmed_rate: #{confirmed_rate} - potential_rate: #{potential_rate}"\
    "\nme(#{sequence.length})\t#{sequence}"\
    "\nel(#{sequence_el.length})\t#{sequence_el}"
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
      if sequence_el[i]&.instance_of?(String)
        current_rate += sequence_el[i-1].rate
      end
    end

    total_pressure == confirmed_rate
  end

  def valid_total_rate
    current_rate = 0
    total_pressure = 0
    sequence.each_with_index.map do |valve, i|
      print "Minutes #{i}\t#{valve}\t#{sequence_el[i]}\t"
      total_pressure += current_rate
      print "\tcurrent_rate\t#{current_rate}\ttotal_pressure\t#{total_pressure}\t"
      if valve.instance_of?(String)
        current_rate += sequence[i-1].rate
        print(sequence[i-1].rate)
      else
        print(0)
      end
      print "\t"
      if sequence_el[i].instance_of?(String)
        current_rate += sequence_el[i-1].rate
        print(sequence_el[i-1].rate)
      else
        print(0)
      end
      print "\n"
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

    tmp2 = []
    # add paths with elephant
    tmp.each do |tmp_path|
      if tmp_path.last_closed_el?
        tmp2 << tmp_path.open_last_el
      end

      # all valves that would lead to useless cycles are removed
      tmp_index = sequence_el.length - 1
      last_valve = sequence_el[tmp_index]
      useless_valves = Set.new
      loop do
        break if last_valve.instance_of?(String)
        useless_valves << last_valve
        tmp_index -= 1
        break if tmp_index < 0
        last_valve = sequence_el[tmp_index]
      end

      tmp_path.last_el.neighbors.reject{|n| useless_valves.include?(n) }.each do |neighbor|
        tmp2 << tmp_path.move_el_to(neighbor)
      end
    end

    tmp2.select{|path| path.potential_rate > $best_path.confirmed_rate }
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

$best_path = nil
10000.times do 
  # greedy algorithm
  current_path = Path.new(closed_valves: closed_valves - [valve_aa], sequence: [valve_aa], sequence_el: [valve_aa], remaining_steps: TOTAL_MINUTES, confirmed_rate: 0)

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

    # move elephant
    if current_path.last_closed_el?
      current_path = current_path.open_last_el
    else
      # if current valve is open, move to max rated neighbor
      next_neighbor = current_path.last_el.neighbors.select { |n| current_path.closed_valves.include?(n) }.sort_by(&:rate).last
      next_neighbor ||= current_path.last_el.neighbors.sample
      current_path = current_path.move_el_to(next_neighbor)
    end
  end

  $best_path = current_path if $best_path.nil? || current_path.confirmed_rate > $best_path.confirmed_rate
end

puts "greedy: #{$best_path}"
puts "\tvalidation:"
$best_path.valid_total_rate

paths_to_explore = MaxHeap.new

start = Path.new(closed_valves: closed_valves - [valve_aa], sequence: [valve_aa], sequence_el: [valve_aa], remaining_steps: TOTAL_MINUTES, confirmed_rate: 0)
paths_to_explore << start

iter = 0
while !paths_to_explore.empty? 
  # paths_to_explore.each do |path|
  #   puts "\t #{path}"
  # end
  
  current_path = paths_to_explore.pop
  if iter % 10_000 == 0
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
