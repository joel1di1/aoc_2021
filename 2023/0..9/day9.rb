# frozen_string_literal: true

require 'readline'
require 'byebug'
require 'set'
require_relative '../../fwk'

lines = File.readlines("#{__dir__}/input9.txt", chomp: true)

histories = lines.map { |l| l.split(' ').map(&:to_i) }

def extrapolate(history)
  sequences = [history]
  level = 0

  until sequences[level].all? { |n| n == 0 }
    sequences[level + 1] = Array.new(sequences[level].size - 1)
    (0...sequences[level].size-1).each do |i|
      sequences[level + 1][i] = sequences[level][i+1] - sequences[level][i]
    end
    level += 1
  end

  # puts sequences.map { |s| s.join(' ') }.join("\n")

  sequences[level] << 0

  level -= 1

  until level < 0
    puts "level: #{level}"
    puts "sequences[level]: #{sequences[level]}"
    puts "sequences[level + 1]: #{sequences[level + 1]}"
    sequences[level].insert(0, sequences[level][0] - sequences[level+1][0])

    level -= 1
  end

  puts sequences.map { |s| s.join(' ') }.join("\n")

  sequences[0][0]
end


puts histories.map { |h| extrapolate(h) }.sum

