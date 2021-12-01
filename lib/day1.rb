require 'readline'

numbers = File.readlines('inputs/day_1.txt').map(&:to_i)

#1
pp (1..numbers.size-1).map{|i| numbers[i] > numbers[i-1] ? 1 : 0}.reduce(:+)

#2
triples = (0..numbers.size-3).map{|i| [numbers[i], numbers[i+1], numbers[i+2]] }
sums = triples.map{|triple| triple.sum }

pp (1..sums.size-1).map{|i| sums[i] > sums[i-1] ? 1 : 0}.reduce(:+)
