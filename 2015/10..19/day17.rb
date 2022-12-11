# frozen_string_literal: true

require 'byebug'

containers = File.readlines('day17.txt').map(&:to_i)

def combinations(containers, target)
  return [[]] if target.zero?
  return [] if target.negative? || containers.empty?

  combinations(containers[1..], target) + combinations(containers[1..], target - containers.first).map do |c|
                                            [containers.first] + c
                                          end
end

combinations_150 = combinations(containers, 150)
pp combinations_150
puts "part1 : #{combinations_150.size}"

min_size = combinations_150.map(&:size).min
puts "part2 : #{combinations_150.select { |c| c.size == min_size }.size}"
