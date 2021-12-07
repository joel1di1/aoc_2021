# frozen_string_literal: true

require 'readline'

def row(seq, rows = (0..127).to_a)
  return rows.first if rows.size == 1

  row(seq[1..], (seq[0] == 'F' || seq[0] == 'L') ? rows[0, rows.size / 2] : rows[(rows.size / 2)..])
end

def seat_id(pass)
  row(pass[0, 7]) * 8 + row(pass[7..], (0..7).to_a)
end

passes = File.readlines('day5.txt')

puts passes.map { |pass| seat_id(pass) }.max
