# frozen_string_literal: true

require 'byebug'
require 'readline'
require 'set'

class BagType
  ALL_BAG_TYPES = {}
  attr_accessor :color

  def self.get(color)
    ALL_BAG_TYPES[color] || ALL_BAG_TYPES[color] = BagType.new(color)
  end

  def contained_by!(other)
    @contained_by_ << other
  end

  # def contains!(other)
  #   @contains_ << other
  # end
  #
  # def contains
  #   @contains_
  # end

  def contained_by
    @contained_by_
  end

  def to_s
    color
  end

  private

  def initialize(color)
    @color = color
    @contained_by_ = Set.new
    # @contains_ = Set.new
  end
end

rules = File.readlines('day7.txt')
rules.each do |rule|
  split = rule.split(' contain ')
  bag = BagType.get(split.first.gsub(/ bags?/, ''))
  next if rule[/contain no other bags/]

  contained_colors = split[1].scan(/\d+\s(\w+ \w+) bag/).flatten
  contained_colors.each do |color|
    contained_bag = BagType.get(color)
    contained_bag.contained_by!(bag)
    # bag.contains!(contained_bag)
  end
end

def rec_valids(valids)
  valids_parents = Set.new(valids.map(&:contained_by).map(&:to_a).flatten)
  return valids if valids >= valids_parents

  rec_valids(valids + valids_parents)
end

valids = rec_valids(Set.new(BagType.get('shiny gold').contained_by))

puts valids.flatten.count
