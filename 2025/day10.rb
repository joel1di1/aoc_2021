require_relative '../fwk'

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
  [diagram, button_texts]
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

lines = File.readlines(File.join(__dir__, 'input10.txt'), chomp: true).reject(&:empty?)

total_presses = lines.sum do |line|
  diagram, button_texts = parse_line(line)
  buttons = button_texts.map { |text| button_mask(text) }
  min_presses(buttons, target_mask(diagram))
end

puts "part 1 : #{total_presses}"
