require 'glpk'
require 'tempfile'

class Machine
  attr_accessor :target, :buttons, :joltages_target

  def initialize(target, buttons, joltages_target)
    self.target = target
    self.buttons = buttons
    self.joltages_target = joltages_target
  end

  def shortest_to_full_on
    target_mask = mask_from_lights(target)
    return 0 if target_mask.zero?

    button_masks = buttons.map { |button| mask_from_indices(button) }
    visited = Array.new(1 << target.size, false)
    queue = Array.new(visited.size)
    head = 0
    tail = 0

    start_mask = 0
    visited[start_mask] = true
    queue[tail] = start_mask
    tail += 1

    steps = 0
    while head < tail
      level_size = tail - head
      level_size.times do
        state = queue[head]
        head += 1
        return steps if state == target_mask

        button_masks.each do |mask|
          next_state = state ^ mask
          next if visited[next_state]

          visited[next_state] = true
          queue[tail] = next_state
          tail += 1
        end
      end
      steps += 1
    end

    Float::INFINITY
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
    begin
      problem = Glpk.read_lp(model.path)
      result = problem.solve(message_level: 0)
    ensure
      Glpk::FFI.glp_term_out(1)
    end
    raise "GLPK failed to solve model for #{joltages_target.inspect} (status: #{result[:status]})" unless [:optimal, :feasible].include?(result[:status])

    result[:col_primal].sum.round
  end

  private

  def mask_from_lights(lights)
    mask_from_indices(lights.each_index.select { |i| lights[i] })
  end

  def mask_from_indices(indices)
    indices.reduce(0) { |mask, idx| mask | (1 << idx) }
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
