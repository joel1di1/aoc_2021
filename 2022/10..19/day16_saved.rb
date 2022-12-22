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
end

class Path
  attr_reader :closed_valves, :sequence, :remaining_steps, :confirmed_rate

  def initialize(closed_valves:, sequence:, remaining_steps:, confirmed_rate:)
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

    # debugger
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

  def next_paths(best_path)
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

    weird = tmp.find{|path| path.potential_rate > self.potential_rate}
    debugger if weird

    tmp.select{|path| path.potential_rate > best_path.confirmed_rate }
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

# puts "\tvalidation:"
# $best_path.valid_total_rate

# test potential rate
# test_valves = [Valve.new('A', 10), Valve.new('B', 20), Valve.new('C', 30)].map{|v| [v.name, v]}.to_h
# assert_eq 56, Path.new(closed_valves: [test_valves['B']], sequence: [test_valves['C']], remaining_steps: 0, confirmed_rate: 56).potential_rate
# assert_eq 56, Path.new(closed_valves: [test_valves['B']], sequence: [test_valves['C']], remaining_steps: 1, confirmed_rate: 56).potential_rate
# assert_eq 76, Path.new(closed_valves: [test_valves['B']], sequence: [test_valves['C']], remaining_steps: 2, confirmed_rate: 56).potential_rate
# assert_eq 56, Path.new(closed_valves: [], sequence: [test_valves['C']], remaining_steps: 200, confirmed_rate: 56).potential_rate
# assert_eq 20, Path.new(closed_valves: [test_valves['B'], test_valves['A']], sequence: [test_valves['C']], remaining_steps: 2, confirmed_rate: 0).potential_rate
# assert_eq 40, Path.new(closed_valves: [test_valves['B'], test_valves['A']], sequence: [test_valves['C']], remaining_steps: 3, confirmed_rate: 0).potential_rate
# assert_eq 70, Path.new(closed_valves: [test_valves['B'], test_valves['A']], sequence: [test_valves['C']], remaining_steps: 4, confirmed_rate: 0).potential_rate
# assert_eq 40, Path.new(closed_valves: [test_valves['B'], test_valves['A']], sequence: [test_valves['B'], 'C'], remaining_steps: 3, confirmed_rate: 0).potential_rate


# puts
# puts Path.new(
#   closed_valves: [valves['TG'], valves['EK'], valves['FG'], valves['EG'], valves['KR'], valves['FX'], valves['VW'], valves['HT'], valves['MS'], valves['AP'], valves['UW'], valves['TQ'], valves['WI'], valves['KS'], valves['WY']], 
#   sequence: [valves['AA'], valves['DX'], valves['WI'], valves['EW'], valves['MT'], valves['FG']], 
#   remaining_steps: 25, confirmed_rate: 0).potential_rate
# puts Path.new(
#   closed_valves: [valves['TG'], valves['EK'], valves['EG'], valves['KR'], valves['FX'], valves['VW'], valves['HT'], valves['MS'], valves['AP'], valves['UW'], valves['TQ'], valves['WI'], valves['KS'], valves['WY']], 
#   sequence: [valves['AA'], valves['DX'], valves['WI'], valves['EW'], valves['MT'], valves['FG'], 'FG'], 
#   remaining_steps: 24, confirmed_rate: 192).potential_rate
# puts


class Searcher
  def initialize(valves, closed_valves, total_minutes)
    @valves = valves
    @closed_valves = closed_valves
    @valve_aa = valves['AA']
    @total_minutes = total_minutes
  end

  def greedy
    # greedy algorithm
    current_path = Path.new(closed_valves: @closed_valves, sequence: [@valve_aa], remaining_steps: TOTAL_MINUTES, confirmed_rate: 0)

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

  def n_greedy(n = 100)
    best_path = nil
    n.times do 
      current_path = greedy
      best_path = current_path if best_path.nil? || current_path.confirmed_rate > best_path.confirmed_rate
    end
    best_path
  end

  # A* algorithm
  def a_star
    paths_to_explore = MaxHeap.new

    start = Path.new(closed_valves: @closed_valves, sequence: [@valve_aa], remaining_steps: @total_minutes, confirmed_rate: 0)
    paths_to_explore << start

    best_path = n_greedy

    iter = 0
    while !paths_to_explore.empty? 
      # paths_to_explore.each do |path|
      #   puts "\t #{path}"
      # end
      
      current_path = paths_to_explore.pop
      # if iter % 20_000 == 0
      #   puts "iter: #{iter}, paths to explore: #{paths_to_explore.size}, $best_path: #{best_path.confirmed_rate}" 
      #   puts "-- exploring #{current_path}"
      # end
      
      iter+=1
      # if current_path.potential_rate <= $best_path.confirmed_rate
      #   puts "path #{current_path} is not worth exploring"
      #   break
      # end
      
      if current_path.confirmed_rate > best_path.confirmed_rate
        best_path = current_path
        # clear paths to explore
        # paths_to_explore = paths_to_explore.select{|p| p.potential_rate > best_path.confirmed_rate }
      end
        
      # add child paths
      current_path.next_paths(best_path).each do |next_path|
        paths_to_explore << next_path
      end
    end

    # puts "best path: #{best_path}"
    # puts "\tvalidation:"
    # best_path.valid_total_rate
    # puts "\n\t==> best confirmed rate: #{best_path.confirmed_rate}\n"
    best_path
  end
end


valves = init_valves
valve_aa = valves['AA']

# marked valves with rate 0 as closed
closed_valves = valves.values.select{|v| v.rate > 0}.freeze
puts "closed_valves: #{closed_valves.length}"

searcher = Searcher.new(valves, closed_valves, 30)

puts "part1: #{searcher.a_star.confirmed_rate}"



# part 2

total_pos = (4..(closed_valves.length/2)).to_a.map { |s| closed_valves.combination(s).count }.sum
puts "total possible combinations: #{total_pos}"

# create all possible s way to split the closed valves into 2 groups
best_value = 0
iter = 0

started_at = Time.now

4.upto(closed_valves.length/2) do |s|
  closed_valves.combination(s).each do |group1|
    group2 = closed_valves - group1
    sum = [group1, group2].map do |group|
      searcher = Searcher.new(valves, group1, 26)
      searcher.a_star.confirmed_rate
    end.sum
    best_value = sum if sum > best_value
    if iter % 10 == 0
      puts "iter: #{iter}, best_value: #{best_value}, remaining: #{total_pos - iter}"
      puts "elapsed: #{Time.now - started_at}"
      puts "remaining: #{(Time.now - started_at) * (total_pos - iter) / iter}"
    end
    iter += 1
  end
end
