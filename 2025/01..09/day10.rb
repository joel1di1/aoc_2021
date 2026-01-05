require_relative '../../fwk'
require 'glpk'
require 'tempfile'

# Solves systems of linear equations over GF(2) (binary field) for minimal solutions
# Used for the light-toggling puzzle where pressing a button twice = not pressing it
class GF2Solver
  # Solves A * x = b (mod 2) to minimize sum(x) using Gaussian elimination + enumeration
  # Returns the minimum number of 1s in solution x, or nil if no solution exists
  def self.solve_min_buttons(buttons, target)
    num_lights = target.size
    num_buttons = buttons.size

    # Build augmented matrix [A | b]
    matrix = Array.new(num_lights) { Array.new(num_buttons + 1, 0) }
    buttons.each_with_index do |button, btn_idx|
      button.each { |light_idx| matrix[light_idx][btn_idx] = 1 }
    end
    target.each_with_index { |is_on, light_idx| matrix[light_idx][num_buttons] = is_on ? 1 : 0 }

    # Gaussian elimination to reduced row echelon form
    pivot_cols = []
    current_row = 0

    (0...num_buttons).each do |col|
      # Find pivot in this column
      pivot_row = (current_row...num_lights).find { |r| matrix[r][col] == 1 }
      next unless pivot_row

      # Swap rows
      matrix[current_row], matrix[pivot_row] = matrix[pivot_row], matrix[current_row]

      # Eliminate in all other rows (not just below)
      (0...num_lights).each do |r|
        next if r == current_row || matrix[r][col] == 0
        (0..num_buttons).each { |c| matrix[r][c] ^= matrix[current_row][c] }
      end

      pivot_cols << col
      current_row += 1
      break if current_row >= num_lights
    end

    # Check for inconsistency
    (current_row...num_lights).each do |row|
      return nil if matrix[row][num_buttons] == 1
    end

    # Identify free variables (columns without pivots)
    free_vars = (0...num_buttons).to_a - pivot_cols

    # If no free variables, unique solution
    if free_vars.empty?
      solution = Array.new(num_buttons, 0)
      pivot_cols.each_with_index do |col, row|
        solution[col] = matrix[row][num_buttons]
      end
      return solution.sum
    end

    # Enumerate all 2^k combinations of free variables to find minimum
    min_presses = Float::INFINITY

    (0...(1 << free_vars.size)).each do |mask|
      solution = Array.new(num_buttons, 0)

      # Set free variables according to mask
      free_vars.each_with_index do |var, i|
        solution[var] = (mask >> i) & 1
      end

      # Back-substitute to find dependent variables
      pivot_cols.each_with_index do |col, row|
        val = matrix[row][num_buttons]
        (0...num_buttons).each do |c|
          val ^= matrix[row][c] * solution[c] if c != col
        end
        solution[col] = val
      end

      min_presses = [min_presses, solution.sum].min
    end

    min_presses
  end
end

# State for Dijkstra search (kept for reference, but GF2Solver is much faster)
# Uncomment if you need to debug or verify GF2 solver results
# class LightState
#   attr_reader :lights, :buttons
#
#   def initialize(lights, buttons)
#     @lights = lights
#     @buttons = buttons
#   end
#
#   def press(button)
#     new_lights = lights.map.with_index { |prev, i| button.include?(i) ? !prev : prev }
#     LightState.new(new_lights, buttons)
#   end
#
#   def neighbors
#     buttons.map { |button| press(button) }
#   end
#
#   def cost(_neighbor)
#     1
#   end
#
#   def ==(other)
#     other.lights == lights
#   end
#
#   def hash
#     lights.hash
#   end
#
#   def eql?(other)
#     self == other
#   end
# end

# Represents a machine with buttons that affect lights and joltages
class Machine
  attr_reader :light_target, :buttons, :joltage_target

  def initialize(light_target, buttons, joltage_target)
    @light_target = light_target
    @buttons = buttons
    @joltage_target = joltage_target
  end

  # Part 1: Find minimum button presses to reach target light configuration
  # Uses GF2 solver (Gaussian elimination over binary field + free variable enumeration)
  # This is O(n^3) for Gaussian elimination + O(2^k) for free variables where k << n
  # Much faster than Dijkstra which explores O(2^n) states in worst case
  def min_presses_for_lights
    GF2Solver.solve_min_buttons(buttons, light_target)
  end

  # Part 2: Find minimum button presses to meet joltage requirements
  # Uses integer linear programming (ILP) via GLPK
  def min_presses_for_joltages
    num_buttons = buttons.size
    num_joltages = joltage_target.size

    # Build coefficient matrix: which buttons affect which joltages
    coefficients = Array.new(num_joltages) { Array.new(num_buttons, 0) }
    buttons.each_with_index do |button, btn_idx|
      button.each { |joltage_idx| coefficients[joltage_idx][btn_idx] = 1 }
    end

    # Generate LP model in CPLEX format
    lp_lines = build_lp_model(coefficients)

    # Solve using GLPK
    solve_with_glpk(lp_lines)
  end

  private

  def build_lp_model(coefficients)
    num_buttons = buttons.size
    num_joltages = joltage_target.size

    lp_lines = []
    lp_lines << "Minimize"
    lp_lines << " obj: #{(0...num_buttons).map { |i| "x#{i}" }.join(' + ')}"
    lp_lines << "Subject To"

    # Each joltage constraint: sum of button presses = target
    (0...num_joltages).each do |joltage_idx|
      terms = (0...num_buttons).filter_map do |btn_idx|
        "x#{btn_idx}" if coefficients[joltage_idx][btn_idx] == 1
      end

      if terms.empty?
        # No buttons affect this joltage - must be zero requirement
        return nil unless joltage_target[joltage_idx].zero?
        next
      end

      lp_lines << " c#{joltage_idx}: #{terms.join(' + ')} = #{joltage_target[joltage_idx]}"
    end

    lp_lines << "Bounds"
    (0...num_buttons).each { |i| lp_lines << " x#{i} >= 0" }
    lp_lines << "Generals"
    lp_lines << " #{(0...num_buttons).map { |i| "x#{i}" }.join(' ')}"
    lp_lines << "End"

    lp_lines
  end

  def solve_with_glpk(lp_lines)
    return Float::INFINITY if lp_lines.nil?

    model_file = Tempfile.new(["glpk_model", ".lp"])
    model_file.write(lp_lines.join("\n") + "\n")
    model_file.close

    # Suppress GLPK output
    Glpk::FFI.extern "int glp_term_out(int flag)" unless Glpk::FFI.respond_to?(:glp_term_out)
    Glpk::FFI.glp_term_out(0)

    problem = Glpk.read_lp(model_file.path)
    result = problem.solve(message_level: 0)

    Glpk::FFI.glp_term_out(1)

    unless [:optimal, :feasible].include?(result[:status])
      raise "GLPK failed: #{result[:status]} for target #{joltage_target.inspect}"
    end

    result[:col_primal].sum.round
  ensure
    model_file.unlink if model_file
  end
end


# Parse input file
# Format: [###.#.##] (0,1,2) (1,3) ... {3,5,2,...}
#   - [###.#.##]: target light configuration (# = on, . = off)
#   - (0,1,2): buttons - each button is a list of light/joltage indices it affects
#   - {3,5,2,...}: joltage target values
def parse_input(filename)
  File.readlines(File.join(__dir__, filename), chomp: true).map do |line|
    # Extract light target: [###.#.##]
    light_pattern = line[/\[(.*?)\]/, 1]
    light_target = light_pattern.chars.map { |c| c == '#' }

    # Extract buttons: (0,1,2) (1,3) ...
    button_strings = line.scan(/\(([^)]+)\)/)
    buttons = button_strings.map { |btn| btn[0].split(',').map(&:to_i) }

    # Extract joltage requirements: {3,5,2,...}
    joltage_pattern = line[/{([^}]+)}/, 1]
    joltage_target = joltage_pattern.split(',').map(&:to_i)

    Machine.new(light_target, buttons, joltage_target)
  end
end

machines = parse_input('input10.txt')

# Part 1: Toggle lights to match target (Gaussian elimination over GF(2))
part1 = machines.map(&:min_presses_for_lights).sum
puts "part 1: #{part1}"

# Part 2: Meet joltage requirements (Integer Linear Programming)
part2 = machines.map(&:min_presses_for_joltages).sum
puts "part 2: #{part2}"
