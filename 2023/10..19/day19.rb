# frozen_string_literal: true

require 'colorize'
require 'readline'
require 'byebug'
require 'set'
require_relative '../../fwk'

class Workflow
  attr_reader :name, :rules, :default

  def initialize(str)
    @name = str[/^([a-z]+)/].to_sym
    rules_str = str.scan(/{(.*)}/)[0][0]
    rules_str, @default = rules_str.scan(/(.*),(\w+)$/)[0]
    @default = @default.to_sym
    rules_strs = rules_str.split(',')
    @rules = rules_strs.map do |rule_str|
      var, op, value, dest = rule_str.scan(/([a-z]+)([<>])(\d+):(\w+)/)[0]
      [var.to_sym, op, value.to_i, dest.to_sym]
    end
  end

  def process(part)
    rules.each do |var, op, value, dest|
      return dest if part[var].send(op, value)
    end
    default
  end
end

workflows = File.readlines("#{__dir__}/input19_w.txt", chomp: true).map { |str| Workflow.new(str) }

workflows_by_name = workflows.map { |workflow| [workflow.name, workflow] }.to_h

initial_ranges = {x: [1, 4000], m: [1, 4000], a: [1, 4000], s: [1, 4000]}

ranges_with_workflows = [[initial_ranges, :in]]

accepted_ranges = []

until ranges_with_workflows.empty?
  current_range, current_w = ranges_with_workflows.pop

  accepted_ranges << current_range if current_w == :A

  next if [:A, :R].include?(current_w)

  current_w = workflows_by_name[current_w]
  current_w.rules.each do |var, op, value, dest|
    # split the range in 2 based on the rule
    split_range = Marshal.load(Marshal.dump(current_range))
    if op == '<'
      split_range[var] = [current_range[var].first, value - 1]
      current_range[var] = [value, current_range[var].last]
    else
      split_range[var] = [value + 1, current_range[var].last]
      current_range[var] = [current_range[var].first, value]
    end

    # add the new range and workflow to the stack
    ranges_with_workflows << [split_range, dest]
  end
  ranges_with_workflows << [current_range, current_w.default]
end

accepted_ranges.map do |range|
  range.values.map do |min, max|
    pos = max - min + 1
    [pos, 0].max
  end.reduce(:*)
end.reduce(:+).display
