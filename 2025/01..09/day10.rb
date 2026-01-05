require_relative '../../fwk'
require 'matrix'
require 'glpk'
require 'tempfile'

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

class JoltageState
  attr_accessor :joltages, :buttons, :target

  def initialize(joltages, buttons, target)
    self.joltages = joltages
    self.buttons = buttons
    self.target = target
  end

  def inspect
    "{#{joltages.join(',')} target: #{target.join(',')}}"
  end

  def to_s
    inspect
  end

  def press(button)
    new_joltages = joltages.map.with_index { |prev, i| button.include?(i) ? prev + 1 : prev }
    JoltageState.new(new_joltages, buttons, target)
  end

  def neighbors
    buttons.map { |button| press(button) }.select(&:valid?)
  end

  def valid?
    (0...target.size).all? do |i|
      joltages[i] <= target[i]
    end
  end

  def cost(_neighbor)
    1    
  end

  def ==(other)
    other.joltages == joltages
  end

  def <=>(other)
    joltages <=> other.joltages
  end

  # implement eveything needed for hash key and comparison
  def hash
    joltages.hash
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
    dijkstra(start_node, end_node, debug_every: 1000)
  end

  def minimum_buttons_pressed_to_meet_joltage_requirements
    num_buttons = buttons.size
    num_joltages = joltages_target.size

    coefficients = Array.new(num_joltages) { Array.new(num_buttons, 0) }
    buttons.each_with_index do |button, button_index|
      button.each do |joltage_index|
        coefficients[joltage_index][button_index] = 1
      end
    end

    lp_lines = []
    lp_lines << "Minimize"
    lp_lines << " obj: #{(0...num_buttons).map { |i| "x#{i}" }.join(' + ')}"
    lp_lines << "Subject To"

    (0...num_joltages).each do |joltage_index|
      terms = (0...num_buttons).filter_map do |button_index|
        "x#{button_index}" if coefficients[joltage_index][button_index] == 1
      end

      if terms.empty?
        return Float::INFINITY unless joltages_target[joltage_index].zero?

        next
      end

      lp_lines << " c#{joltage_index}: #{terms.join(' + ')} = #{joltages_target[joltage_index]}"
    end

    lp_lines << "Bounds"
    (0...num_buttons).each { |i| lp_lines << " x#{i} >= 0" }
    lp_lines << "Generals"
    lp_lines << " #{(0...num_buttons).map { |i| "x#{i}" }.join(' ')}"
    lp_lines << "End"

    model = Tempfile.new(["glpk_model", ".lp"])
    model.write(lp_lines.join("\n") + "\n")
    model.close

    Glpk::FFI.extern "int glp_term_out(int flag)" unless Glpk::FFI.respond_to?(:glp_term_out)
    Glpk::FFI.glp_term_out(0)
    problem = Glpk.read_lp(model.path)
    result = problem.solve(message_level: 0)
    Glpk::FFI.glp_term_out(1)
    raise "GLPK failed to solve model for #{joltages_target.inspect} (status: #{result[:status]})" unless [:optimal, :feasible].include?(result[:status])

    result[:col_primal].sum.round
  end
end


lines = File.readlines(File.join(__dir__, 'input10.txt'), chomp: true)

machines = lines.map do |line|
  target = line[/\[(.*)\]/][1...-1].chars.map { |c| c == '#' }
  buttons = line[/\((.*)\)/].split.map { |str| str[1...-1].split(',').map(&:to_i) }
  joltage_requirements = line[/{(.*)}/][1...-1].split(',').map(&:to_i)
  
  Machine.new(target, buttons, joltage_requirements)
end


# puts "part 1 : #{machines.map(&:shortest_to_full_on).reduce(:+)}"
puts "part 2 : #{machines.map(&:minimum_buttons_pressed_to_meet_joltage_requirements).reduce(:+)}"
