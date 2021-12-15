# frozen_string_literal: true

require_relative '../../fwk'

def read_inputs(file)
  lines = File.readlines(file)
  sequence = lines.first.strip
  rules = lines[2..].each_with_object({}) do |line, rules|
    split = line.split(' -> ')
    rules[split[0]] = split[1].strip
  end
  [rules, sequence]
end

def step(sequence, rules)
  chars = sequence.chars
  new_sequence = []
  (0..chars.size - 1).each do |i|
    new_sequence << chars[i]
    new_sequence << rules["#{chars[i]}#{chars[i + 1]}"]
  end
  new_sequence.join
end

def process(file, nb_iter)
  rules, sequence = read_inputs(file)

  # puts "init: #{sequence}"
  nb_iter.times.with_index do |i|
    # puts "step #{i}"
    sequence = step(sequence, rules)
  end

  occurences = sequence.chars.tally.to_a.map { |_c, nb| nb }
  puts "[1] #{file} (#{nb_iter}): #{occurences.max - occurences.min}"
end

process("day14_sample.txt", 10)
process("day14.txt", 10)

def count_seq(sequence, rules, nb_iteration, cache = {})
  cache_key = [sequence, nb_iteration]
  cached = cache[cache_key]
  if cached
    # puts "hit cache for #{cache_key}"
    cached
  else
    # puts "compute #{cache_key}"
    new_value = if sequence.size <= 1 || nb_iteration.zero?
      sequence.chars.tally
    else
      sequence = step(sequence, rules)
      pairs = (0..sequence.size - 2).map { |i| sequence[i, 2] }
      hashes = pairs.map do |pair|
        count_seq(pair, rules, nb_iteration -1, cache)
      end
      res = hashes.each_with_object({}) do |h, acc|
        h.each do |char, count|
          acc[char] ||= 0
          acc[char] += count
        end
      end
      pairs[0..-2].map { |s| s[-1] }.each { |c| res[c] -= 1 }
      res
    end
    cache[[sequence, nb_iteration]] = new_value
    new_value
  end
end

def part2(file, nb_iter, cache = {})
  rules, sequence = read_inputs(file)
  start = sequence[0]
  last = sequence[-1]

  pairs = (0..sequence.size - 2).map { |i| sequence[i, 2] }
  pair_occurences = pairs.tally
  nb_iter.times do
    pair_occurences = pair_occurences.each_with_object({}) do |entry, h|
      pair, occurences = entry
      c = rules[pair]
      ["#{pair[0]}#{c}", "#{c}#{pair[1]}"].each do |new_pair|
        h[new_pair] ||= 0
        h[new_pair] += occurences
      end
    end
  end

  puts pair_occurences
  h = pair_occurences.each_with_object({}) do |entry, h|
    pair, occurence = entry
    pair.chars.each do |c|
      h[c] ||= 0
      h[c] += occurence
    end
  end
  h[start] += 1
  h[last] += 1
  (h.values.max - h.values.min) / 2
end

rules = { 'CN' => 'C' }

assert_eq({ 'N' => 1 }, count_seq('N', rules, 0))
assert_eq({ 'N' => 1, 'C' => 1 }, count_seq('CN', rules, 0))
assert_eq({ 'N' => 2, 'C' => 2 }, count_seq('CNCN', rules, 0))

assert_eq({ 'N' => 1, 'C' => 2 }, count_seq('CN', rules, 1))

# rules, sequence = read_inputs('day14_sample.txt')
# assert_eq({ 'N' => 2, 'C' => 2, 'B' => 2, 'H' => 1 }, count_seq(sequence, rules, 1))

assert_eq 1588, part2('day14_sample.txt', 10)
assert_eq 2194, part2("day14.txt", 10)

# cache = {}
# part2("day14.txt", 10, cache)
puts part2("day14_sample.txt", 10)

puts 'YOUPI !!!'
`git add . && git commit -am 'green autocommit'`