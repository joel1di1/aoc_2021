# frozen_string_literal: true

require 'readline'
require 'byebug'
require 'set'

def process(file)
  lines = File.readlines(file)

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
      value |= one_mask
      value &= zero_mask
      mem[index] = value
    end
  end
  puts "res: #{mem.compact.sum}"
end

process('day14_sample.txt')
process('day14.txt')

def compute_indexes(initial_value, floating_mask, x_indexes)
  x_count = floating_mask.count('X')
  (0..((2**x_count)-1)).map do |sol_index|
    replace = sol_index.to_s(2).chars
    chars = initial_value.to_s(2).rjust(36, '0').chars
    x_indexes.each do |x_index|
      chars[x_index] = replace.pop
      break if replace.empty?
    end
    chars.join.to_i(2)
  end
end

def process2(file)
  lines = File.readlines(file)

  one_mask = nil
  floating_mask = nil
  zero_mask = nil
  mem = {}
  x_indexes = {}
  lines.each do |line|
    case line
    when /mask = (.*)/
      mask = Regexp.last_match(1)
      one_mask = mask.gsub('X', '0').to_i(2)
      zero_mask = mask.gsub(/[01]/, '1').gsub('X', '0').to_i(2)
      floating_mask = mask.gsub('1', '0')
      x_indexes = floating_mask.chars.map.with_index{|c, i| c == 'X' ? i : nil}.compact.reverse
    when /mem\[(\d+)\] = (\d+)/
      address = Regexp.last_match(1).to_i & zero_mask
      value = Regexp.last_match(2).to_i
      address |= one_mask
      addresses = compute_indexes(address, floating_mask, x_indexes)
      addresses.each do |address|
        mem["#{address}"] = value
      end
    end
  end
  puts "res: #{mem.values.sum}"
end

process2('day14_sample2.txt')
process2('day14.txt')
