require_relative '../../fwk'

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
  attr_accessor :target, :buttons

  def initialize(target, buttons)
    self.target = target
    self.buttons = buttons
  end

  def valid?
    lights == target
  end

  def shortest_to_full_on
    start_node = MachineState.new(target.map { false }, buttons)
    end_node = MachineState.new(target, buttons)
    dijkstra(start_node, end_node, debug_every: 1000)
  end
end


lines = File.readlines(File.join(__dir__, 'input10.txt'), chomp: true)

machines = lines.map do |line|
  target = line[/\[(.*)\]/][1...-1].chars.map { |c| c == '#' }
  buttons = line[/\((.*)\)/].split.map { |str| str[1...-1].split(',').map(&:to_i) }
  # joltage_requirements_str = line[/{(.*)}/]
  
  Machine.new(target, buttons)
end


puts "part 1 : #{machines.map(&:shortest_to_full_on).reduce(:+)}"
puts "part 2 : #{}"


