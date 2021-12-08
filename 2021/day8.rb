# frozen_string_literal: true

require 'readline'
require 'byebug'

def decode(codes)
  table = {}
  codes_per_length = {}
  (2..7).map { |i| codes_per_length[i] = [] }
  codes.reduce(codes_per_length) { |table, code| codes_per_length[code.length] << code }

  table[1] = codes_per_length[2].first
  table[7] = codes_per_length[3].first
  table[4] = codes_per_length[4].first
  table[8] = codes_per_length[7].first
  table[6] = codes_per_length[6].find { |code| !(table[1].chars - code.chars).empty? }

  table[9] = (codes_per_length[6] - [table[6]]).find { |code| (table[4].chars - code.chars).empty? }
  table[0] = (codes_per_length[6] - [table[6], table[9]]).first

  bottom_left = (table[8].chars - table[9].chars).first
  table[2] = codes_per_length[5].find { |code| code.chars.include? bottom_left }

  four_minus_one = table[4].chars - table[1].chars
  table[5] = (codes_per_length[5] - [table[2]]).find { |code| four_minus_one.all? { |c| code.chars.include? c } }

  table[3] = (codes_per_length[5] - [table[2], table[5]]).first

  table.reduce({}) do |h, e|
    h[e[1]] = e[0]
    h
  end
end

def process(file)
  sum = File.readlines(file).map do |l|
    split = l.split(' | ')
    codes = split[0].split.map { |s| s.chars.sort.join }
    digits = split[1].split.map { |s| s.chars.sort.join }

    table = decode(codes)
    digits.map { |d| table[d].to_s}.join.to_i
  end.sum

  puts "#{file}: #{sum}"
end

process('day8_sample.txt')
process('day8.txt')
