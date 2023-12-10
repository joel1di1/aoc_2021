# frozen_string_literal: true

require 'readline'
require 'byebug'
require 'set'
require_relative '../../fwk'

lines = File.readlines("#{__dir__}/input7.txt", chomp: true)

HEAD_VALUES = { 'T' => 10, 'J' => 11, 'Q' => 12, 'K' => 13, 'A' => 14 }.freeze

class Hand
  attr_accessor :cards, :values, :ranks, :bid

  def initialize(cards, bid)
    @cards = cards
    @values = cards.chars.map { |card| HEAD_VALUES[card] || card.to_i }

    @bid = bid
    @ranks = values.each_with_object(Hash.new(0)) do |e, total| 
      total[e] += 1
    end.values.sort.reverse
  end

  def <=>(other)
    res = @ranks <=> other.ranks

    return res unless res == 0

    @values <=> other.values
  end
end

hands = lines.map do |line|
  left, right = line.split(' ')
  Hand.new(left, right.to_i)
end

hands.sort!

total_win = hands.map.with_index do |hand, index|
  hand.bid * (index + 1)
end.sum

puts "Total win: #{total_win}"
