# frozen_string_literal: true

require 'set'
require 'byebug'
require_relative '../../fwk'

class AmphipodCantMoveError < StandardError
end

class Sequence
  attr_reader :amphipod_positions, :cost, :target_per_type, :empty_spaces, :amphipod_positions_without_moved, :previous

  def initialize(amphipod_positions, cost, target_per_type, empty_spaces, previous = nil)
    # hash of amphipod position to type
    # key is position, value is hash with type (String) and moved (Boolean)
    @amphipod_positions = amphipod_positions.freeze
    @cost = cost
    @target_per_type = target_per_type.freeze
    @empty_spaces = empty_spaces.freeze

    @amphipod_positions_without_moved = deep_dup(@amphipod_positions)
    @amphipod_positions_without_moved.each do |position, amphipod|
      amphipod.delete(:moved)
    end

    @previous = previous
  end

  def distance(position1, position2)
    return 0 if position1 == position2

    # if column are different, move up to raw 1 and then move to the right raw
    # so distance if (position1.x - 1) + (position2.x - 1) + (position1.y - position2.y)
    (position1.first - 1) + (position2.first - 1) + (position1.last - position2.last).abs
  end

  # return the heuristic cost to move the amphipods to reach their position to target
  def heuristic_cost_to_target
    free_amphipods = deep_dup(@amphipod_positions)
    target_to_fill = deep_dup(@target_per_type)

    # remove amphipods that are already in their target position
    target_to_fill.each do |type, targets|
      free_amphipods.find do |position, amphipod|
        if amphipod[:type] == type && targets.include?(position)
          targets.delete(position)
          free_amphipods.delete(position)
        end
      end
    end

    target_to_fill.map do |type, targets|
      targets.map do |target|
        # find the closest amphipod
        closest = nil
        free_amphipods.select { |position, amphipod| amphipod[:type] == type }.each do |position, amphipod|
          dist = distance(position, target)
          if closest.nil? || dist < closest[:dist]
            closest = { position: position, dist: dist, amphipod: amphipod }
          end
        end
        
        # remove the closest amphipod from the free ones
        debugger if closest.nil?
        free_amphipods.delete(closest[:position])

        cost_for_distance(closest[:dist], closest[:amphipod][:type])
      end.sum
    end.sum + @cost
  end

  def ==(other)
    @amphipod_positions_without_moved == other.amphipod_positions_without_moved
  end

  def <=>(other)
    @amphipod_positions_without_moved.to_s <=> other.amphipod_positions_without_moved.to_s
  end

  # return all possible paths from current state. Only one amphipod moves at a time.
  # for each amphipods, next paths would be :
  #  amphipod moves to destination if possible
  #  amphipod moves to a possible empty space
  def nexts
    nexts = []
    @amphipod_positions.each do |position, amphipod|
      nexts += nexts_for(position, amphipod)
    end
    nexts
  rescue AmphipodCantMoveError
    []
  end

  def already_in_final_position?(amphipod, position)
    return false unless @target_per_type[amphipod[:type]].include?(position)

    # check if there is no amphipod of a different type in target position with a higher x
    @target_per_type[amphipod[:type]].all? do |target|
      target.first <= position.first ||
      @amphipod_positions[target].nil? || 
      @amphipod_positions[target][:type] == amphipod[:type]
    end
  end

  # return every possible sequence of moves for an amphipod to an empty space
  # empty array if no empty space
  def moves_to_empty_space(amphipod, position)
    # return empty array if amphipod already moved
    return [] if amphipod[:moved]
    return [] if already_in_final_position?(amphipod, position)

    # for every empty space, check if an amphipod is already there
    # if not, check if path is blocked
    # if not, create a new sequence with the amphipod moved to the empty space
    @empty_spaces.keys.map do |empty_space|
      next if @amphipod_positions[empty_space]
      next if path_blocked?(position, empty_space)
      next if [3,5,7,9].include?(empty_space.last)
      next if blocking_position?(amphipod, empty_space)
      
      new_sequence_for_unblocked_move(amphipod, position, empty_space)
    end.compact
  end

  def blocking_position?(amphipod, empty_space)
    empty_space_column = empty_space.last

    return false if empty_space_column < 3 || empty_space_column > 9

    # will block if a B becomes right of C, with B right of B column and left of C column
    # and C left of C column and right of B column
    case amphipod[:type]
    when 'A'
      return true if empty_space_column == 6 && types_in_empty_space?(['C', 'D'], [4])
      return true if empty_space_column == 8 && types_in_empty_space?(['D'], [6])
    when 'D'
      return true if empty_space_column == 4 && types_in_empty_space?(['A'], [6, 8])
      return true if empty_space_column == 6 && types_in_empty_space?(['A', 'B'], [8])
    end

    return false
  end

  # empty_space_column is array of integers for columns
  # types is array of strings for types
  def types_in_empty_space?(types, empty_space_column)
    empty_space_column.any? do |column|
      types.include?(@amphipod_positions[[1, column]]&.[](:type))
    end
  end

  def nexts_for(position, amphipod)
    nexts = []
    # move to destination
    nexts << move_to_destination(amphipod, position)

    # move to empty space
    nexts << moves_to_empty_space(amphipod, position)
    nexts = nexts.flatten.compact

    # raise error if amphipod can't move and is not in final position
    if nexts.empty? && !already_in_final_position?(amphipod, position)
      raise AmphipodCantMoveError.new("amphipod can't move") 
    end

    nexts
  end

  def first_empty_target_space(type)
    # return nil if every space is occupied by another amphipod
    return nil if @target_per_type[type].all? { |target| @amphipod_positions[target] }

    # return nil if one space is occupied by another amphipod with a different type
    return nil if @target_per_type[type].any? { |target| @amphipod_positions[target] && @amphipod_positions[target][:type] != type }

    # return the empty space with the highest x
    @target_per_type[type].reject { |target| @amphipod_positions[target] }.max_by { |target| target[0] }
  end

  def path_blocked?(position, destination)
    # check if path is blocked by another amphipod
    # list every position between position and destination
    # we want to move first on the y axis, then on the x axis
    # if any of these positions is occupied by an amphipod, return true
    x_position, y_position = position
    x_destination, y_destination = destination

    # if x_position > 1, move on x axis until x_position = 1
    if x_position > 1
      # move on y axis until x_position = 1
      # if any position is occupied by an amphipod, return true
      (x_position - 1).downto(1) do |x|
        x_position = x
        return true if @amphipod_positions[[x_position, y_position]]
      end
    end

    # the move on y axis until y_position = y_destination
    until y_position == y_destination
      if y_position < y_destination
        y_position += 1
      else
        y_position -= 1
      end
      return true if @amphipod_positions[[x_position, y_position]]
    end

    # if x_destination > 1, move on x axis until x_destination = 1
    if x_destination > 1
      # move on x axis until x_position = 1
      # if any position is occupied by an amphipod, return true
      (x_position + 1).upto(x_destination - 1) do |x|
        x_position = x
        return true if @amphipod_positions[[x_position, y_position]]
      end
    end

    # if we reach this point, the path is not blocked
    false
  end

  def move_to_destination(amphipod, position)
    destination = first_empty_target_space(amphipod[:type])
    return nil if destination.nil?
    
    return nil if path_blocked?(position, destination)

    return nil if @amphipod_positions[destination] == position

    new_sequence_for_unblocked_move(amphipod, position, destination)
  end

  def cost_for_distance(distance, type)
    case type
    when 'A'
      distance
    when 'B'
      distance * 10
    when 'C'
      distance * 100
    when 'D'
      distance * 1000
    end
  end

  def new_sequence_for_unblocked_move(amphipod, position, destination)
    # cost is manhattan distance between position and destination
    dist = distance(position, destination)
    tmp_cost = cost_for_distance(dist, amphipod[:type])

    new_positions = deep_dup(@amphipod_positions)
    new_positions[destination] = deep_dup(amphipod)
    new_positions[destination][:moved] = true
    new_positions.delete(position)
    Sequence.new(new_positions, @cost + tmp_cost, @target_per_type, @empty_spaces, self)
  end

  def self.parse(file)
    lines = File.readlines(file).map(&:chomp)
    empty_spaces = [1,2,4,6,8,10,11].map{|y| [[1,y], '.' ]}.to_h
    amphipods = {}
    lines.each_with_index do |line, x|
      line.chars.each_with_index do |char, y|
        if char[/[ABCD]/]
          amphipods[[x, y]] = { type: char, moved: false }
        end
      end
    end

    target_per_type = {'A' => [], 'B' => [], 'C' => [], 'D' => []}
    (2..(lines.size-2)).each do |x|
      target_per_type['A'] << [x, 3]
      target_per_type['B'] << [x, 5]
      target_per_type['C'] << [x, 7]
      target_per_type['D'] << [x, 9]
    end

    Sequence.new(amphipods, 0, target_per_type, empty_spaces)
  end

  def display
    all_positions = @empty_spaces.merge(@amphipod_positions)
    min_x, max_x = all_positions.keys.map(&:first).minmax
    min_y, max_y = all_positions.keys.map(&:last).minmax
    (min_x..max_x).each do |x|
      (min_y..max_y).each do |y|
        if all_positions[[x, y]]
          if all_positions[[x, y]].is_a?(String)
            print all_positions[[x, y]]
          else
            print all_positions[[x, y]][:type]
          end
        else
          print ' '
        end
      end
      puts
    end
  end

  def display_all_sequence
    # get the array of all previous sequences
    # display them in order
    all_sequences = [self]
    current = self
    until current.previous.nil?
      all_sequences << current.previous
      current = current.previous
    end

    all_sequences.reverse.each do |sequence|
      sequence.display
      puts "\tcost: #{sequence.cost}\n\n"
    end
  end
end

def solve_part1(file)
  puts "\n-- solving part 1 for file #{file}"
  solve(file, 'day23_files/day23_part1_target.txt')
end

def solve_part2(file)
  puts "\n-- solving part 2 for file #{file}"
  solve(file, 'day23_files/day23_part2_target.txt')
end

def solve(file, target_file)
  sequence = Sequence.parse(file)
  # sequence.display

  # create the target Sequence
  target = Sequence.parse(target_file)
  # target.display

  # make a bfs to find the shortest path
  # use a set to store already visited sequences
  visited = Set.new

  queue = PriorityQueue.new
  queue.push(sequence, sequence.heuristic_cost_to_target)

  best_found = nil

  iter = 0

  until queue.empty?
    current, tmp_cost = queue.pop

    if iter % 10_000 == 0
      puts "iter: #{iter}, queue size: #{queue.size}, visited size: #{visited.size}, current cost: #{current.cost}, heuristic cost: #{current.heuristic_cost_to_target}"
      puts "\tcurrent:"
      current.display
      puts "\tbest found: #{best_found.cost}" if best_found
    end
    iter += 1

    if best_found && current.heuristic_cost_to_target >= best_found.cost
      puts "current cost #{current.cost} is greater than best found cost #{best_found.cost}"
      puts "best found with cost #{best_found.cost} in #{iter} moves"
      best_found.display
      puts " ====================\n\n"
      return best_found
    end

    if current == target
      if best_found.nil? || current.cost < best_found.cost
        best_found = current
      end
    end

    nexts = current.nexts

    if nexts.include?(target)
      next_sequence = nexts.find{|seq| seq == target}
      queue.push(next_sequence, next_sequence.heuristic_cost_to_target)
    else
      nexts.each do |next_sequence|

        # puts "next sequence:"
        # next_sequence.display

        unless visited.include?(next_sequence)
          visited << next_sequence
          # debugger if next_sequence.heuristic_cost_to_target < current.heuristic_cost_to_target
          queue.push(next_sequence, next_sequence.heuristic_cost_to_target)
        end
      end
    end
  end
rescue Interrupt
  puts "Interrupted"
ensure
  puts "\nbest found with cost #{best_found&.cost} in #{iter-1} moves"
  best_found&.display_all_sequence
end

def tests
  sequence = Sequence.parse('day23_part1.txt')
  assert sequence.path_blocked?([3,3], [1,3])

  assert_eq 18214, sequence.heuristic_cost_to_target
  sequence1 = sequence.new_sequence_for_unblocked_move(sequence.amphipod_positions[[2,3]], [2,3], [1,4])
  assert_eq 18214, sequence1.heuristic_cost_to_target

  assert_eq 0, Sequence.parse('day23_files/day23_part1_target.txt').heuristic_cost_to_target

  assert_eq Sequence.parse('day23_files/day23_heuristic_1.txt').heuristic_cost_to_target, Sequence.parse('day23_files/day23_heuristic_2.txt').heuristic_cost_to_target + 200



  solve_part1('day23_files/day23_0.txt')
  # sequence = Sequence.parse('day23_files/day23_1.txt')
  # sequence.nexts_for([1, 4], {:type=>"B", :moved=>false}).each { |next_sequence| next_sequence.display }
  solve_part1('day23_files/day23_1.txt')
  puts 'Tests OK'
end

# tests

# best = solve('day23_sample.txt')
# best.display_all_sequence
# solve('day23_part1.txt')

solve_part1('day23_part1.txt')

# solve_part2('day23_part2.txt')