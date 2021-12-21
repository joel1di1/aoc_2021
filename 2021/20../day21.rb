# frozen_string_literal: true

require_relative '../../fwk'

class Dice
  def initialize
    @i = -1
  end

  def value
    (@i % 100) + 1
  end

  def roll
    @i += 1
    value
  end

  def nb_rolls
    @i + 1
  end
end

def play(p1_pos, p2_pos)
  player1 = { position: p1_pos - 1, score: 0 }
  player2 = { position: p2_pos - 1, score: 0 }

  dice = Dice.new

  players = [player1, player2]
  turn = 0
  until players.any? { |p| p[:score] >= 1000 }
    turn += 1
    player = players[(turn - 1) % 2]
    3.times do
      dice.roll
      player[:position] = (player[:position] + dice.value) % 10
    end
    player[:score] += player[:position] + 1
  end
  puts players
  puts dice.nb_rolls
  puts "res: #{players.map{|p| p[:score]}.min * dice.nb_rolls}"
end

play(4, 8)
play(4, 3)