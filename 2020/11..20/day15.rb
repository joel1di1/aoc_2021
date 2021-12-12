# frozen_string_literal: true

require 'readline'
require 'byebug'
require 'set'

def process(init_numbers, target)
  spoken = [nil]
  previous_last_indexes = {}   # {0: [1, 3, 12, 23, ]}

  init_numbers.each.with_index do |num, iter|
    spoken << num
    last = spoken.last
    previous_last_indexes[last] ||= []
    previous_last_indexes[last] << iter + 1
  end

  start_time = Time.now

  ((init_numbers.size)..target-1).each do |iter|
    # if iter % 50_000 == 0
    #   puts "#{iter}, #{Time.now - start_time}"
    #   start_time = Time.now
    # end

    last = spoken.last
    previous_last_index = previous_last_indexes[last][-2]
    if previous_last_index.nil?
      spoken << 0
    else
      spoken << iter - previous_last_index
    end
    previous_last_indexes[spoken.last] ||= []
    previous_last_indexes[spoken.last] << iter + 1
  end

  # puts "#{spoken}"

  puts "#{target} th for #{init_numbers}: #{spoken.last}"
end


process([0, 3, 6], 10)
process([2, 1, 3], 2020)
process([1, 2, 3], 2020)
process([2, 3, 1], 2020)
process([1, 3, 2], 2020)
process([3, 2, 1], 2020)
process([3, 1, 2], 2020)

process([7,12,1,0,16,2], 2020)

process([7,12,1,0,16,2], 30_000_000 )