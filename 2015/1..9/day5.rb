# frozen_string_literal: true

require_relative '../../fwk'

require 'byebug'

def nice?(str)
  return false unless str[/[aeiou].*[aeiou].*[aeiou]/]
  return false unless str[/(.)\1{1,}/]
  return false if str[/(ab)|(cd)|(pq)|(xy)/]

  true
end

assert nice?('ugknbfddgicrmopn')
assert nice?('aaa')
assert !nice?('jchzalrnumimnmhp')
assert !nice?('haegwjzuvuyypxyu')
assert !nice?('dvszwmarrgswjxmb')

nice_lines = File.readlines('day5.txt').map do |line|
  nice?(line) ? 1 : 0
end.sum

puts "part1: #{nice_lines}"

def true_nice?(str)
  return false unless str[/(.).\1{1,}/]
  return false unless str[/(.)(.).*\1\2{1,}/]

  true
end

assert true_nice?('qjhvhtzxzqqjkmpb')
assert true_nice?('xxyxx')
assert !true_nice?('uurcxstgmygtbstg')
assert !true_nice?('ieodomkazucvgmuy')

true_nice_lines = File.readlines('day5.txt').map do |line|
  true_nice?(line) ? 1 : 0
end.sum

puts "part2: #{true_nice_lines}"
