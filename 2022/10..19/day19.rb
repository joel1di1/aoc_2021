### term : 1 old code, real data
### term : 2 new code, sample data
### term : 3 old code, sample data

require 'byebug'
require 'set'
require_relative '../../fwk'

INDEX_TO_RESOURCE = {nil => nil, 0 => :ore, 1 => :clay, 2 => :obsidian, 3 => :geode}.freeze

$best_sequence = nil

class Blueprint
  attr_reader :id, :blueprint
  def initialize(id, blueprint)
    @id = id
    @blueprint = blueprint
  end

  def self.from_line(line)
    capts = line.match(/Blueprint (\d+): Each ore robot costs (\d+) ore. Each clay robot costs (\d+) ore. Each obsidian robot costs (\d+) ore and (\d+) clay. Each geode robot costs (\d+) ore and (\d+) obsidian./).captures
    blueprint = {
      ore: {ore: capts[1].to_i} ,
      clay: {ore: capts[2].to_i},
      obsidian: {ore: capts[3].to_i, clay: capts[4].to_i},
      geode: {ore: capts[5].to_i, obsidian: capts[6].to_i}
    }
    self.new(capts[0].to_i, blueprint)
  end
end

class Sequence
  attr_reader :bots, :resources, :sequence

  @@cache = {}

  def initialize(blueprint, 
                 bots = {ore: 1, clay: 0, obsidian: 0, geode: 0}, 
                 resources = {ore: 0, clay: 0, obsidian: 0, geode: 0},
                 sequence = [])
    @blueprint = blueprint
    @bots = bots.freeze
    @resources = resources.freeze
    @sequence = sequence.freeze
  end

  def to_s
    "length: #{@sequence.length}, "\
    "sequence: #{@sequence.map { |choice| (INDEX_TO_RESOURCE[choice] || "--")[0..1] }.join(",")} "\
    "potential_geodes: #{potential_geodes},"\
    "resources: #{@resources}, bots: #{@bots}"
  end

  def geodes
    @resources[:geode]
  end

  # returns true if it's possible, false otherwise
  # returns false if time spent
  def possible?(next_choice)
    # check time
    return false if @sequence.length + 1 > MINUTES

    bot_to_build = INDEX_TO_RESOURCE[next_choice]

    return true if bot_to_build.nil?

    # check if we have enough resources
    @blueprint.blueprint[bot_to_build].all? { |resource, needed_amount| @resources[resource] >= needed_amount }
  end

  def could_have_build_last_turn(next_choice)
    @sequence.last.nil? && 
      @blueprint.blueprint[INDEX_TO_RESOURCE[next_choice]].all? { |resource, needed_amount| @resources[resource] >= needed_amount + @bots[resource] }
  end

  # returns a new sequence if it's possible, nil otherwise
  # returns nil if time spent
  def next_sequence(next_choice)
    # check if it's possible
    return nil unless possible?(next_choice)
    return nil if next_choice && could_have_build_last_turn(next_choice)

    # construct new sequence
    new_bots = deep_dup(@bots)
    new_resources = deep_dup(@resources)
    new_sequence = deep_dup(@sequence)

    # apply next choice
    bot_to_build = INDEX_TO_RESOURCE[next_choice]

    # if we're building a bot, add it to the bots and subtract the resources
    if bot_to_build
      new_bots[bot_to_build] += 1
      @blueprint.blueprint[bot_to_build].each do |resource, amount|
        new_resources[resource] -= amount
      end
    end

    # add the resources
    @bots.each do |resource, amount|
      new_resources[resource] += amount
    end

    # add the choice to the sequence
    new_sequence << next_choice

    # return the new sequence
    next_sequence = Sequence.new(@blueprint, new_bots, new_resources, new_sequence)
    # puts "next sequence: #{next_sequence}"
    next_sequence
  end

  def next_sequences
    return [] if potential_geodes == 0

    [nil,0,1,2,3].map do |next_choice|
      next_sequence(next_choice)
    end.compact
  end

  def length
    @sequence.length
  end

  def <=>(other)
    return 0 if self == other
    
    res = self.weight <=> other.weight
    res = self.length <=> other.length if res == 0

    -res
  end

  def potential_geodes
    potential(:geode)
  end

  def time_to_get_resource(resource, amount)
    remaining_amount = amount - @resources[resource]

    additional_bots = 0
    while remaining_amount > 0
      remaining_amount -= @bots[resource] + additional_bots
      additional_bots += 1
    end
    additional_bots
  end

  def time_to_first_bot(resource)
    return 0 if @bots[resource] > 0

    @blueprint.blueprint[resource].map do |resource, amount|
      time_to_get_resource(resource, amount) + 1
    end.max
  end

  def potential(resource)
    if resource != :ore
      @blueprint.blueprint[resource].each do |resource, amount|
        return 0 if potential(resource) < amount
      end 
    end

    remaining_time = MINUTES - @sequence.length - time_to_first_bot(resource)
    @resources[resource] + 
      (@bots[resource] * (remaining_time)) + 
      (0..[remaining_time,0].max).inject(:+)
  end
end



MINUTES = 32
file = 'day19.txt'

puts "sloving #{file}, #{MINUTES} minutes"

blueprints = File.readlines(file).map {|l| Blueprint.from_line(l) }

bests = []
sum_quality_level = blueprints[0..2].map do |blueprint|
  sequence = Sequence.new(blueprint, {ore: 1, clay: 0, obsidian: 0, geode: 0}, {ore: 0, clay: 0, obsidian: 0, geode: 0}, [])
  $best_sequence = sequence
  
  sequences_to_try = PriorityQueue.new
  sequences_to_try.push(sequence, sequence.potential_geodes)
  
  i = 0
  until sequences_to_try.empty?
    sequence, _ = sequences_to_try.pop

    next if sequence.length > MINUTES
    next if $best_sequence && sequence.potential_geodes < $best_sequence.geodes
  
    $best_sequence = sequence if $best_sequence.nil? || sequence.geodes > $best_sequence.geodes
  
    # add next sequences to the inspection list
    sequence.next_sequences.each do |next_sequence|
      sequences_to_try.push(next_sequence, next_sequence.potential_geodes)
    end

    if i % 100_000 == 0
      puts "================= #{blueprint.id}, it: #{i} , best: #{$best_sequence.geodes}, bests: #{bests}====================" 
      puts "\texploring sequence: #{sequence}"
    end

    i += 1
  end  

  puts "finished blueprint #{blueprint.id} in #{i} iterations, best: #{$best_sequence.geodes}"
  bests << $best_sequence.geodes
  blueprint.id * $best_sequence.geodes
end.sum

puts "sum_quality_level: #{sum_quality_level}"
puts "product of bests: #{bests.inject(:*)}"