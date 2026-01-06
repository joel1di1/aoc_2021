require_relative '../fwk'
require 'open3'
require 'tempfile'
require 'timeout'

Machine = Struct.new(:diagram, :buttons, :joltage, keyword_init: true)

# Precompute XOR and size for every subset of the given masks.
def subset_xors(masks)
  n = masks.size
  total = 1 << n
  xors = Array.new(total, 0)
  weights = Array.new(total, 0)

  (1...total).each do |i|
    prev = i & (i - 1)
    bit = i ^ prev
    idx = bit.bit_length - 1
    xors[i] = xors[prev] ^ masks[idx]
    weights[i] = weights[prev] + 1
  end

  [xors, weights]
end

# Meet-in-the-middle minimum presses to reach a target XOR.
def min_presses(button_masks, target)
  half = button_masks.size / 2
  left = button_masks[0...half]
  right = button_masks[half..] || []

  left_min = Hash.new(Float::INFINITY)
  left_xors, left_weights = subset_xors(left)
  left_xors.each_with_index do |xor, i|
    weight = left_weights[i]
    left_min[xor] = weight if weight < left_min[xor]
  end

  right_xors, right_weights = subset_xors(right)
  best = Float::INFINITY
  right_xors.each_with_index do |xor, i|
    total = right_weights[i] + left_min[target ^ xor]
    best = total if total < best
  end

  best
end

# Parse a comma-separated list of indices.
def parse_indices(text)
  return [] if text.strip.empty?

  text.split(',').map(&:to_i)
end

# Convert a diagram like ".#.#" into a bitmask of lit lights.
def target_mask(diagram)
  mask = 0
  diagram.chars.each_with_index do |char, idx|
    mask |= (1 << idx) if char == '#'
  end
  mask
end

# Convert button indices into a bitmask toggle.
def button_mask(button_text)
  parse_indices(button_text).reduce(0) do |mask, idx|
    mask | (1 << idx)
  end
end

# Extract diagrams, button texts, and joltage targets from input lines.
def parse_machines(lines)
  lines.map do |line|
    diagram = line[/\[(.*?)\]/, 1]
    button_texts = line.scan(/\((.*?)\)/).map(&:first)
    joltage = line[/\{(.*?)\}/, 1].to_s.split(',').map(&:to_i)
    Machine.new(diagram: diagram, buttons: button_texts, joltage: joltage)
  end
end

# Build a GLPK LP/MIP program for the joltage counters.
def glpk_lp(buttons, targets)
  var_names = (1..buttons.size).map { |i| "x#{i}" }
  lp = "Minimize\n obj: #{var_names.join(' + ')}\nSubject To\n"

  targets.size.times do |i|
    terms = []
    buttons.each_with_index do |indices, j|
      terms << var_names[j] if indices.include?(i)
    end
    lp << " c#{i + 1}: #{terms.join(' + ')} = #{targets[i]}\n"
  end

  lp << "Bounds\n"
  var_names.each { |name| lp << " #{name} >= 0\n" }
  lp << "Generals\n #{var_names.join(' ')}\nEnd\n"
  lp
end

# Solve the LP/MIP with glpsol and return the objective value.
def solve_glpk(lp)
  Tempfile.create(['aoc_day10', '.lp']) do |file|
    Tempfile.create(['aoc_day10', '.sol']) do |sol|
      file.write(lp)
      file.flush
      _stdout, _stderr, status = Open3.capture3(
        'glpsol',
        '--lp',
        file.path,
        '--output',
        sol.path
      )
      return nil unless status.success?

      obj_line = File.readlines(sol.path).find { |line| line.include?('Objective:') }
      return nil unless obj_line

      obj_line[/=\s*([0-9.+-eE]+)/, 1].to_i
    end
  end
end

# Minimize total presses to hit exact joltage targets.
def min_presses_joltage(buttons, targets)
  solve_glpk(glpk_lp(buttons, targets))
end

lines = File.readlines(File.join(__dir__, 'input10.txt'), chomp: true).reject(&:empty?)
machines = parse_machines(lines)

total_presses = machines.sum do |machine|
  button_masks = machine.buttons.map { |text| button_mask(text) }
  min_presses(button_masks, target_mask(machine.diagram))
end

puts "part 1 : #{total_presses}"

begin
  Timeout.timeout(10) do
    total_joltage = machines.sum do |machine|
      buttons = machine.buttons.map { |text| parse_indices(text) }
      min_presses_joltage(buttons, machine.joltage)
    end

    puts "part 2 : #{total_joltage}"
  end
rescue Timeout::Error
  puts "part 2 : timeout"
end
