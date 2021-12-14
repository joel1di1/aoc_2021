# frozen_string_literal: true

require_relative '../../fwk'

def readinputs(file)
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
  rules, sequence = readinputs(file)

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
  cache_key = [sequence, nb_iteration]
  cache.fetch(cache_key) do
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

puts 'YOUPI !!!'
`git add . && git commit -am 'green autocommit'`