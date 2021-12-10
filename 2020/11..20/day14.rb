# frozen_string_literal: true

require 'readline'
require 'byebug'
require 'set'

def process(file)
  lines = File.readlines(file)

  mask = nil
  one_mask = nil
  zero_mask = nil
  mem = []
  lines.each do |line|
    case line
    when /mask = (.*)/
      mask = Regexp.last_match(1)
      one_mask = mask.gsub('X', '0').to_i(2)
      zero_mask = mask.gsub('X', '1').to_i(2)
    when /mem\[(\d+)\] = (\d+)/
      index = Regexp.last_match(1).to_i
      value = Regexp.last_match(2).to_i
      value = value | one_mask
      value = value & zero_mask
      mem[index] = value
    end
  end
  puts "res: #{mem.compact.sum}"
end

process('day14_sample.txt')
process('day14.txt')