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

def process(file)
  rules, sequence = read_inputs(file)

  puts "init: #{sequence}"
  10.times.with_index do |i|
    puts "step #{i}"
    sequence = step(sequence, rules)
    # puts "step#{i+1}: #{sequence}"
  end

  occurences = sequence.chars.tally.to_a.map { |_c, nb| nb }
  puts occurences.max - occurences.min

end

process("day14.txt")

def count_seq(sequence, rules, nb_iteration, cache = {})
  cache.fetch([sequence, nb_iteration]) do
    if sequence.size <= 1 || nb_iteration.zero?
      sequence.chars.tally
    else
      new_sequence = step(sequence, rules)
      count_seq(new_sequence, rules, nb_iteration - 1, cache)
    end
  end
end

rules = { 'CN' => 'C' }

assert_eq({ 'N' => 1 }, count_seq('N', rules, 0))
assert_eq({ 'N' => 1, 'C' => 1 }, count_seq('CN', rules, 0))
assert_eq({ 'N' => 2, 'C' => 2 }, count_seq('CNCN', rules, 0))

assert_eq({ 'N' => 1, 'C' => 2 }, count_seq('CN', rules, 1))

rules, sequence = read_inputs('day14_sample.txt')
assert_eq({ 'N' => 2, 'C' => 2, 'B' => 2, 'H' => 1 }, count_seq(sequence, rules, 1))


rules, sequence = read_inputs('day14.txt')
count_seq(sequence, rules, 10)

puts 'YOUPI !!!'
`git add . && git commit -am 'green autocommit'`