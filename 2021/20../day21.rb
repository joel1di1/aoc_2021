# frozen_string_literal: true

require_relative '../../fwk'

class Universe
  attr_reader :players
  attr_accessor :count, :turn

  def self.universes_by_positions
    @universes_by_positions ||= {}
  end

  def initialize(players, turn, count = 1)
    @players = players.map(&:dup)
    @count = count
    @turn = turn
  end

  def split
    Universe.new(players, turn, count)
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
end

def merge(universes)
  new_us_by_players = {}
  universes.each do |universe|
    key = universe.players + [universe.turn]
    new_us_by_players[key] ||= universe
    new_us_by_players[key].count += universe.count if new_us_by_players[key] != universe
  end
  new_us_by_players.values
end

def play(p1_pos, p2_pos)
  player1 = { position: p1_pos - 1, score: 0 }
  player2 = { position: p2_pos - 1, score: 0 }
  dice = Dice.new

  wining_score = 21

  universes = [Universe.new([player1, player2], -1)]
  unfinished_universes = universes.dup
  step = 0
  until unfinished_universes.empty?
    step += 1
    puts "step: #{step}"
    puts "still #{unfinished_universes.count} unfinished universes"

    unfinished_universes.each do |universe|
      # puts "Unfinished universe: #{universe}"
      universe.turn = (universe.turn + 1) % 2
      player_index = universe.turn
      local_universes = [universe]
      3.times do
        new_universes = []
        local_universes.each do |universe1|
          dice.roll
          universe2 = universe1.split
          universe3 = universe1.split
          new_universes << universe2
          new_universes << universe3

          player_universe1 = universe1.players[player_index]
          player_universe2 = universe2.players[player_index]
          player_universe3 = universe3.players[player_index]

          player_universe1[:position] = (player_universe1[:position] + 1) % 10
          player_universe2[:position] = (player_universe2[:position] + 2) % 10
          player_universe3[:position] = (player_universe3[:position] + 3) % 10
        end
        local_universes.concat(new_universes)
      end
      local_universes.each do |universe|
        player = universe.players[player_index]
        player[:score] += player[:position] + 1
      end
      universes.concat(local_universes)
    end

    universes = merge(universes.uniq)
    unfinished_universes = universes.reject { |universe| universe.players.any? { |p| p[:score] >= wining_score } }
  end

  victories = [0, 0]
  universes.each { |u| u.players.first[:score] >= 21 ? victories[0] += u.count : victories[1] += u.count }
  puts "victories; #{victories}, max: #{victories.max}"
end

play(4, 8)
play(4, 3)
