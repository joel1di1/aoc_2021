# frozen_string_literal: true

require 'readline'
require 'byebug'
require 'set'
require_relative '../../fwk'

lines = File.readlines('input4.txt').map(&:strip)

worths = lines.map do |line|
  _left, right = line.split(':')
  wining_numbers, my_numbers = right.split('|').map(&:strip)

  wining_numbers = wining_numbers.split(' ').map(&:to_i)
  wining_numbers_set = Set.new(wining_numbers)
  my_numbers = my_numbers.split(' ').map(&:to_i)

  points = 0
  my_numbers.each do |my_number|
    if wining_numbers_set.include?(my_number)
      if points == 0
        points = 1
      else
        points *= 2
      end
    end
  end
  points
end

puts "part1: #{worths.sum}"


card_wins = {}
lines.map.with_index do |line, i|
  _left, right = line.split(':')
  wining_numbers, my_numbers = right.split('|').map(&:strip)

  wining_numbers = wining_numbers.split(' ').map(&:to_i)
  wining_numbers_set = Set.new(wining_numbers)
  my_numbers = my_numbers.split(' ').map(&:to_i)

  # numbers of my numbers that are winning numbers
  my_winning_numbers = my_numbers.select { |my_number| wining_numbers_set.include?(my_number) }

  card_wins[i] = [my_winning_numbers.count, 1]
end

i = 0
while i < card_wins.size
  nb_win, nb_cards = card_wins[i]
  if nb_win > 0
    (1..nb_win).each do |j|
      card_wins[i + j][1] += nb_cards if i + j < card_wins.size
    end
  end
  i+=1
end

puts "part2: #{card_wins.values.map { |c| c[1] }.sum}}"
