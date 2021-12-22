# frozen_string_literal: true

require_relative '../../fwk'

class Universe
  attr_reader :dice, :players

  def initialize(dice, players)
    @dice = dice.dup
    @players = players.map(&:dup)
  end
end

class Dice
  def initialize(i = -1)
    @i = i
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

  def dup
    Dice.new(@i)
  end
end

def play(p1_pos, p2_pos)
  player1 = { position: p1_pos - 1, score: 0 }
  player2 = { position: p2_pos - 1, score: 0 }
  universes = [Universe.new(Dice.new, [player1, player2])]

  wining_score = 1000

  turn = 0
  until universes.all? { |universe| universe.players.any? { |p| p[:score] >= wining_score } }
    turn += 1
    fixed_universes = universes.reject { |universe| universe.players.any?  { |p| p[:score] >= wining_score } }

    fixed_universes.each do |universe|
      player = universe.players[(turn - 1) % 2]
      3.times do
        universe.dice.roll
        player[:position] = (player[:position] + universe.dice.value) % 10
      end
      player[:score] += player[:position] + 1
    end
  end


  puts universes.first.players
  puts universes.first.dice.nb_rolls
  puts "res: #{universes.first.players.map { |p| p[:score] }.min * universes.first.dice.nb_rolls}"
end

play(4, 8)
play(4, 3)