require_relative '../../fwk'
require 'matrix'


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

class JoltagePossibility
  attr_accessor :joltages, :requirements, :buttons

  def initialize(joltages, requirements, buttons)
    self.joltages = joltages
    self.requirements = requirements
    self.buttons = buttons
  end

  def inspect
    "{#{joltages.join(',')}} req: {#{requirements.join(',')}} buttons: {#{buttons.map { |b| b.join(',') }.join(' | ')}}"
  end

  def to_s
    inspect
  end

  def valid?
    (0...requirements.size).all? do |i|
      joltages[i] <= requirements[i]
    end
  end

  def neighbors
    # take the first requirement that is not yet met
    # search all buttons that can increase it
    # create the combinations of pressing those buttons that will met the requirement
    # select only the valid ones
    generations = []
    (0...requirements.size).each do |i|
      next if joltages[i] >= requirements[i]

      buttons_that_increase = buttons.select { |b| b.include?(i) }
      # generate all combinations of pressing those buttons
      combinations = (1..buttons_that_increase.size).flat_map do |n|
        buttons_that_increase.combination(n).to_a
      end

      combinations.each do |combination|
        new_joltages = joltages.dup
        combination.each do |button|
          button.each do |index|
            new_joltages[index] += 1
          end
        end

        possibility = JoltagePossibility.new(new_joltages, requirements, buttons)
        generations << possibility if possibility.valid?
      end

      break
    end
    generations
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
    # we will use linear programming to solve this problem
    # solution will be an array of integers, each representing how many times to press each button
    # exemple: [2, 0, 1] means press button 0 two times, button 1 zero times, button 2 one time
    
    # for each requirement, we will create an equation
    # start manually for now
    
    # joltage_1 = N0 * b0_1 + N1 * b1_1 + N2 * b2_1 + ...
    # joltage_2 = N0 * b0_2 + N1 * b1_2 + N2 * b2_2 + ...
    # ...
    # where N is the number of times to press each button
    # and b is 1 if the button increases the joltage at that index, 0 otherwise
    
    # we want to minimize the sum of N0 + N1 + N2 + ...

    matrix = buttons.map do |button|
      target.map.with_index { |_, i| button.include?(i) ? 1 : 0 }
    end.transpose
    debugger
    b = joltages_target
    aa = Matrix[*matrix]
    b_vector = Vector.elements(b)
    x = aa.inverse * b_vector
    presses = x.to_a.map(&:round)

    presses.sum
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
puts "part 2 : #{machines.map(&:minimum_buttons_pressed_to_meet_joltage_requirements).reduce(:+)}}"


