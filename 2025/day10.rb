require_relative '../fwk'
require 'timeout'

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

def rref(matrix, rhs)
  rows = matrix.size
  cols = matrix.first.size
  aug = matrix.map.with_index do |row, r|
    row.map { |v| Rational(v, 1) } + [Rational(rhs[r], 1)]
  end

  pivot_cols = []
  r = 0
  c = 0
  while r < rows && c < cols
    pivot = (r...rows).find { |i| aug[i][c] != 0 }
    if pivot.nil?
      c += 1
      next
    end

    aug[r], aug[pivot] = aug[pivot], aug[r] if pivot != r
    pivot_val = aug[r][c]
    aug[r].map! { |v| v / pivot_val }

    (0...rows).each do |i|
      next if i == r
      factor = aug[i][c]
      next if factor == 0
      aug[i] = aug[i].zip(aug[r]).map { |a, b| a - factor * b }
    end

    pivot_cols << c
    r += 1
    c += 1
  end

  aug.each do |row|
    all_zero = row[0...cols].all?(&:zero?)
    return nil if all_zero && row[cols] != 0
  end

  [aug, pivot_cols]
end

def min_presses_joltage(buttons, targets)
  n = targets.size
  m = buttons.size
  matrix = Array.new(n) { Array.new(m, 0) }
  buttons.each_with_index do |indices, j|
    indices.each { |i| matrix[i][j] = 1 }
  end

  result = rref(matrix, targets)
  return nil if result.nil?
  aug, pivot_cols = result

  free_cols = (0...m).to_a - pivot_cols
  free_count = free_cols.size

  upper_bounds = buttons.map do |indices|
    indices.map { |idx| targets[idx] }.min
  end

  pivot_rows = {}
  pivot_cols.each_with_index { |col, row| pivot_rows[col] = row }

  pivot_exprs = pivot_cols.map do |col|
    row = aug[pivot_rows[col]]
    const = row[m]
    coeffs = free_cols.map { |fcol| -row[fcol] }
    { col: col, const: const, coeffs: coeffs, ub: upper_bounds[col] }
  end

  free_bounds = free_cols.map { |col| upper_bounds[col] }

  total_coeffs = free_cols.map.with_index do |_col, i|
    coeff = Rational(1, 1)
    pivot_exprs.each do |expr|
      coeff += expr[:coeffs][i]
    end
    coeff
  end

  best = Float::INFINITY
  assigned = Array.new(free_count, 0)

  dfs = lambda do |idx, assigned_sum|
    pivot_exprs.each do |expr|
      min = expr[:const]
      max = expr[:const]
      expr[:coeffs].each_with_index do |coeff, j|
        val = j < idx ? assigned[j] : nil
        if j < idx
          min += coeff * val
          max += coeff * val
        else
          ub = free_bounds[j]
          if coeff >= 0
            max += coeff * ub
          else
            min += coeff * ub
          end
        end
      end

      low = min.ceil
      high = max.floor
      return if high < 0
      return if low > expr[:ub]
    end

    min_total = assigned_sum
    pivot_exprs.each do |expr|
      min = expr[:const]
      expr[:coeffs].each_with_index do |coeff, j|
        val = j < idx ? assigned[j] : nil
        if j < idx
          min += coeff * val
        else
          ub = free_bounds[j]
          min += coeff.negative? ? coeff * ub : 0
        end
      end
      min_total += min
    end
    return if min_total >= best

    if idx == free_count
      pivot_vals = pivot_exprs.map do |expr|
        val = expr[:const]
        expr[:coeffs].each_with_index { |coeff, j| val += coeff * assigned[j] }
        return unless val.denominator == 1
        int_val = val.to_i
        return if int_val.negative? || int_val > expr[:ub]
        int_val
      end

      total = assigned_sum + pivot_vals.sum
      best = total if total < best
      return
    end

    ub = free_bounds[idx]
    if total_coeffs[idx] >= 0
      range = 0..ub
    else
      range = ub.downto(0)
    end
    range.each do |val|
      assigned[idx] = val
      dfs.call(idx + 1, assigned_sum + val)
    end
  end

  dfs.call(0, 0)
  best.finite? ? best : nil
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
