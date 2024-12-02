require 'readline'
require 'byebug'
require 'set'
require_relative '../../fwk'

lines = File.readlines(File.join(__dir__, 'input2.txt'))

positive = proc { |x| x > 0 }
negative = proc { |x| x < 0 }

safes = lines.map do |line|
  reports = line.split.map(&:to_i)
  safe = true
  case reports[0] - reports[1]
    when 0
      safe = false
      inc = 0
    when positive
      inc = -1
    when negative
      inc = 1
  end

  (0...reports.size - 1).each do |i|
    diff = -(reports[i] - reports[i + 1])
    if !(diff * inc > 0 && diff * inc <= 3)
      safe = false
      break 0
    end
  end

  safe ? 1 : 0
end.sum

puts "part1: #{safes}"
