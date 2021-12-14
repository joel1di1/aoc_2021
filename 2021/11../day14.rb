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

def count_seq(sequence, nb_iteration)
  sequence.chars.tally
end

assert_eq({ 'N' => 1 }, count_seq('N', 0))
assert_eq({ 'N' => 1, 'C' => 1 }, count_seq('CN', 0))

puts 'YOUPI !!!'
`git add . && git commit -am 'green autocommit'`