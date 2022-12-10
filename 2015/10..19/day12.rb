# frozen_string_literal: true

require 'json'
require 'byebug'

line = File.readlines('day12.txt').first
puts "part1 :  #{line.scan(/(-?\d+)/).flatten.map(&:to_i).sum}"

json = JSON.parse line

def sum_not_red(element)
  return element if element.instance_of? Integer

  if element.instance_of? Hash
    values = element.map { |_k, v| v }
    return 0 if values.include?('red')

    return values.compact.map { |val| sum_not_red(val) }.sum
  elsif element.instance_of? Array
    return element.compact.map { |val| sum_not_red(val) }.sum
  end
  0
end

sum = sum_not_red(json)
puts "part2 : #{sum}"
