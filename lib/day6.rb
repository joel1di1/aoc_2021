# frozen_string_literal: true

require 'readline'
require 'byebug'

class Lanternfish
  def initialize(timer)
    @timer = timer
  end

  def live_a_day
    if @timer.zero?
      @timer = 6
      return Lanternfish.new(8)
    end
    @timer -= 1
    nil
  end
end

def process(nb_days, initial_states)
  lanternfishes = initial_states.map { |i| Lanternfish.new(i) }
  (1..nb_days).each do
    new_lanterns = lanternfishes.map(&:live_a_day).compact
    lanternfishes.concat(new_lanterns)
  end
  puts lanternfishes.count
end

sample = [3, 4, 3, 1, 2]
process 80, sample
input = [4, 2, 4, 1, 5, 1, 2, 2, 4, 1, 1, 2, 2, 2, 4, 4, 1, 2, 1, 1, 4, 1, 2, 1, 2, 2, 2, 2, 5, 2, 2, 3, 1, 4, 4, 4, 1,
         2, 3, 4, 4, 5, 4, 3, 5, 1, 2, 5, 1, 1, 5, 5, 1, 4, 4, 5, 1, 3, 1, 4, 5, 5, 5, 4, 1, 2, 3, 4, 2, 1, 2, 1, 2, 2, 1, 5, 5, 1, 1, 1, 1, 5, 2, 2, 2, 4, 2, 4, 2, 4, 2, 1, 2, 1, 2, 4, 2, 4, 1, 3, 5, 5, 2, 4, 4, 2, 2, 2, 2, 3, 3, 2, 1, 1, 1, 1, 4, 3, 2, 5, 4, 3, 5, 3, 1, 5, 5, 2, 4, 1, 1, 2, 1, 3, 5, 1, 5, 3, 1, 3, 1, 4, 5, 1, 1, 3, 2, 1, 1, 1, 5, 2, 1, 2, 4, 2, 3, 3, 2, 3, 5, 1, 5, 1, 2, 1, 5, 2, 4, 1, 2, 4, 4, 1, 5, 1, 1, 5, 2, 2, 5, 5, 3, 1, 2, 2, 1, 1, 4, 1, 5, 4, 5, 5, 2, 2, 1, 1, 2, 5, 4, 3, 2, 2, 5, 4, 2, 5, 4, 4, 2, 3, 1, 1, 1, 5, 5, 4, 5, 3, 2, 5, 3, 4, 5, 1, 4, 1, 1, 3, 4, 4, 1, 1, 5, 1, 4, 1, 2, 1, 4, 1, 1, 3, 1, 5, 2, 5, 1, 5, 2, 5, 2, 5, 4, 1, 1, 4, 4, 2, 3, 1, 5, 2, 5, 1, 5, 2, 1, 1, 1, 2, 1, 1, 1, 4, 4, 5, 4, 4, 1, 4, 2, 2, 2, 5, 3, 2, 4, 4, 5, 5, 1, 1, 1, 1, 3, 1, 2, 1]
process 80, input

# part 2

def process_fast(input, nb_days)
  lanterns = input.tally
  (1..nb_days).each do
    new_lanterns = {}
    lanterns.each do |timer, nb_lanterns|
      if timer.zero?
        new_lanterns[6] = (new_lanterns[6] || 0) + nb_lanterns
        new_lanterns[8] = (new_lanterns[8] || 0) + nb_lanterns
      else
        new_lanterns[timer - 1] = (new_lanterns[timer - 1] || 0) + nb_lanterns
      end
    end
    lanterns = new_lanterns
  end
  lanterns.values.sum
end

pp process_fast(sample, 80)
pp process_fast(sample, 256)
pp process_fast(input, 80)
pp process_fast(input, 256)
