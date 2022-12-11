# frozen_string_literal: true

require 'byebug'

REG = /((\w+): (\d+))/

aunt_sue = {
  'children' => 3,
  'cats' => 7,
  'samoyeds' => 2,
  'pomeranians' => 3,
  'akitas' => 0,
  'vizslas' => 0,
  'goldfish' => 5,
  'trees' => 3,
  'cars' => 2,
  'perfumes' => 1
}

sues = File.readlines('day16.txt').map(&:strip).map do |line, _index|
  line.scan(/((\w+): (\d+))/).map { |v| [v[1], v[2].to_i] }.to_h
end

sues.each_with_index do |sue, index|
  puts "part1: #{index + 1}" if sue.all? { |k, v| aunt_sue[k] == v }
end

aunt_sue = {
  'children' => ->(v) { v == 3 },
  'cats' => ->(v) { v > 7 },
  'samoyeds' => ->(v) { v == 2 },
  'pomeranians' => ->(v) { v < 3 },
  'akitas' => ->(v) { v.zero? },
  'vizslas' => ->(v) { v.zero? },
  'goldfish' => ->(v) { v < 5 },
  'trees' => ->(v) { v > 3 },
  'cars' => ->(v) { v == 2 },
  'perfumes' => ->(v) { v == 1 }
}

sues.each_with_index do |sue, index|
  puts "part2: #{index + 1}" if sue.all? { |k, v| aunt_sue[k].call(v) }
end
