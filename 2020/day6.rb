
# frozen_string_literal: true

require 'readline'
require 'set'

groups = File.read('day6.txt').split("\n\n").map{|g| g.split}

a =  groups.map do |group|
  q = Set.new
  group.map{|answers| q.merge answers.chars}
  q.size
end.sum

puts a