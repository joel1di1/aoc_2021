# frozen_string_literal: true

require 'byebug'

LINE_REGEXP = %r{(?<name>\w+) can fly (?<speed>\d+) km/s for (?<fly_period>\d+) seconds, but then must rest for (?<rest_period>\d+) seconds}

reindeers = {}
File.readlines('day14.txt').each do |line|
  captures = LINE_REGEXP.match(line)
  reindeers[captures[:name]] =
    { speed: captures[:speed].to_i, fly_period: captures[:fly_period].to_i, rest_period: captures[:rest_period].to_i }
end

# from array, initialize a hash with keys being the elements of the array and values being 0
def init_hash(array)
  hash = {}
  array.each do |element|
    hash[element] = 0
  end
  hash
end

reindeers_array = reindeers.keys
positions = init_hash(reindeers_array)
scores = init_hash(reindeers_array)

2503.times do |iter|
  # puts "current second: #{iter+1}"
  reindeers.each do |name, reindeer|
    moving = (iter % (reindeer[:fly_period] + reindeer[:rest_period])) < reindeer[:fly_period]
    positions[name] += reindeer[:speed] if moving
    # puts "after #{iter+1}s, #{name} #{positions[name]} km (moved: #{moving})"
  end

  max = positions.values.max
  positions.each { |name, position| scores[name] += 1 if position == max }
end

# puts positions
puts "Part1: #{positions.values.max}"
puts "Part1: #{scores.values.max}"
