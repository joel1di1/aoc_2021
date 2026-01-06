require_relative '../fwk'
require 'timeout'
require 'open3'
require 'tempfile'

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

def parse_line(line)
  diagram = line[/\[(.*?)\]/, 1]
  button_texts = line.scan(/\((.*?)\)/).map(&:first)
  joltage_text = line[/\{(.*?)\}/, 1]
  joltage = joltage_text ? joltage_text.split(',').map(&:to_i) : []
  [diagram, button_texts, joltage]
end

def target_mask(diagram)
  mask = 0
  diagram.chars.each_with_index do |char, idx|
    mask |= (1 << idx) if char == '#'
  end
  mask
end

def button_mask(button_text)
  return 0 if button_text.strip.empty?

  button_text.split(',').map(&:to_i).reduce(0) do |mask, idx|
    mask | (1 << idx)
  end
end

def button_indices(button_text)
  return [] if button_text.strip.empty?

  button_text.split(',').map(&:to_i)
end

def min_presses_joltage(buttons, targets)
  vars = buttons.size
  constraints = targets.size
  var_names = (1..vars).map { |i| "x#{i}" }

  lp = +"Minimize\n obj: "
  lp << var_names.join(' + ')
  lp << "\nSubject To\n"

  constraints.times do |i|
    terms = []
    buttons.each_with_index do |indices, j|
      terms << var_names[j] if indices.include?(i)
    end
    lp << " c#{i + 1}: #{terms.join(' + ')} = #{targets[i]}\n"
  end

  lp << "Bounds\n"
  var_names.each { |name| lp << " #{name} >= 0\n" }
  lp << "Generals\n "
  lp << var_names.join(' ')
  lp << "\nEnd\n"

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

lines = File.readlines(File.join(__dir__, 'input10.txt'), chomp: true).reject(&:empty?)

total_presses = lines.sum do |line|
  diagram, button_texts, _joltage = parse_line(line)
  buttons = button_texts.map { |text| button_mask(text) }
  min_presses(buttons, target_mask(diagram))
end

puts "part 1 : #{total_presses}"

begin
  Timeout.timeout(10) do
    total_joltage = lines.sum do |line|
      _diagram, button_texts, joltage = parse_line(line)
      buttons = button_texts.map { |text| button_indices(text) }
      min_presses_joltage(buttons, joltage)
    end

    puts "part 2 : #{total_joltage}"
  end
rescue Timeout::Error
  puts "part 2 : timeout"
end
