# frozen_string_literal: true

require 'byebug'
require 'readline'
require 'set'

class BagType
  def self.all_bags
    @all_bags ||= {}
  end

  def self.get(color)
    all_bags[color] || all_bags[color] = BagType.new(color)
  end

  attr_reader :color, :contains, :contained_by

  def contained_by!(other)
    @contained_by << other
  end

  def contains!(other, number)
    @contains << [other, number]
  end

  def count_capacity
    return 0 if @contains.empty?

    @contains.map { |_c, number| number }.sum + @contains.map { |c, number| c.count_capacity * number }.sum
  end

  def to_s
    color
  end

  private

  def initialize(color)
    @color = color
    @contained_by = Set.new
    @contains = []
  end
end

rules = File.readlines('day7.txt')
rules.each do |rule|
  split = rule.split(' contain ')
  bag = BagType.get(split.first.gsub(/ bags?/, ''))
  next if rule[/contain no other bags/]

  contained_colors = split[1].scan(/(\d+)\s(\w+ \w+) bag/).flatten
  Hash[*contained_colors.reverse].each do |color, number|
    contained_bag = BagType.get(color)
    contained_bag.contained_by!(bag)
    bag.contains!(contained_bag, number.to_i)
  end
end

def rec_valids(valids)
  valids_parents = Set.new(valids.map(&:contained_by).map(&:to_a).flatten)
  return valids if valids >= valids_parents

  rec_valids(valids + valids_parents)
end

valids = rec_valids(Set.new(BagType.get('shiny gold').contained_by))
puts valids.flatten.count

puts BagType.get('shiny gold').count_capacity
