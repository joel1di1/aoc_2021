require_relative '../fwk'
require 'matrix'
require 'glpk'

class MachineState
  attr_accessor :lights, :buttons

  def initialize(lights, buttons)
    self.lights = lights
    self.buttons = buttons
  end

  def inspect
    "[#{lights.map { |l| l ? '#': '.' }.join}]"
  end

  def to_s
    inspect
  end

  def press(button)
    new_lights = lights.map.with_index { |prev, i| button.include?(i) ? !prev : prev }
    MachineState.new(new_lights, buttons)
  end

  def neighbors
    buttons.map { |button| press(button) }
  end

  def cost(_neighbor)
    1    
  end

  def ==(other)
    other.lights == lights
  end

  def <=>(other)
    lights <=> other.lights
  end

  # implement eveything needed for hash key and comparison
  def hash
    lights.hash
  end
  
  def eql?(other)
    self == other
  end
end

class Machine
  attr_accessor :target, :buttons, :joltages_target

  def initialize(target, buttons, joltages_target)
    self.target = target
    self.buttons = buttons
    self.joltages_target = joltages_target
  end

  def shortest_to_full_on
    start_node = MachineState.new(target.map { false }, buttons)
    end_node = MachineState.new(target, buttons)
    dijkstra(start_node, end_node)
  end

  def minimum_buttons_pressed_to_meet_joltage_requirements
    mat_ia = []  # row indices
    mat_ja = []  # col indices
    mat_ar = []  # values

    # fill the GLPK sparse matrix arrays
    buttons.each_with_index do |button, i|
      button.each do |val|
        mat_ia << (val + 1) # GLPK uses 1-based indexing
        mat_ja << (i + 1) # GLPK uses 1-based indexing
        mat_ar << 1
      end
    end

    problem = Glpk.load_problem(
      obj_dir: :minimize,
      obj_coef: buttons.map { 1 },
      mat_ia: mat_ia,
      mat_ja: mat_ja,
      mat_ar: mat_ar,
      row_lower: joltages_target,
      row_upper: joltages_target,
      col_lower: buttons.map { 0 },
      col_upper: buttons.map { 100000 },
      col_kind: buttons.map { :integer }
    )

    # Solve the LP
    solution = problem.solve
    solution[:col_primal].sum.to_i
  end
end


lines = File.readlines(File.join(__dir__, 'input10.txt'), chomp: true)

machines = lines.map do |line|
  target = line[/\[(.*)\]/][1...-1].chars.map { |c| c == '#' }
  buttons = line[/\((.*)\)/].split.map { |str| str[1...-1].split(',').map(&:to_i) }
  joltage_requirements = line[/{(.*)}/][1...-1].split(',').map(&:to_i)
  
  Machine.new(target, buttons, joltage_requirements)
end

puts "part 1 : #{machines.map(&:shortest_to_full_on).reduce(:+)}"
puts "part 2 : #{machines.map(&:minimum_buttons_pressed_to_meet_joltage_requirements).reduce(:+)}"

