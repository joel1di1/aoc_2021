require 'byebug'
require 'set'

INDEX_TO_RESOURCE = {nil => nil, 0 => :ore, 1 => :clay, 2 => :obsidian, 3 => :geode}.freeze

$best_sequence = nil

def deep_dup(obj)
  case obj
  when Array
    obj.map { |item| deep_dup(item) }
  when Hash
    obj.each_with_object({}) { |(key, value), copy| copy[key] = deep_dup(value) }
  else
    obj.dup
  end
end

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
    "resources: #{@resources}, bots: #{@bots}, weight: #{weight}"
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
    return false if @blueprint.blueprint[bot_to_build].any? { |resource, needed_amount| @resources[resource] < needed_amount }

    !previous_choice_is_nil_but_we_had_enough_resources_to_build_the_bot(bot_to_build)
  end

  def previous_choice_is_nil_but_we_had_enough_resources_to_build_the_bot(bot_to_build)
    @sequence.last.nil? && 
      @blueprint.blueprint[bot_to_build].all? { |resource, needed_amount| @resources[resource] >= needed_amount + @bots[resource] }
  end

  # returns a new sequence if it's possible, nil otherwise
  # returns nil if time spent
  def next_sequence(next_choice)
    # check if it's possible
    return nil unless possible?(next_choice)

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
    return [] if @sequence.length >= MINUTES
    return [] if $best_sequence && potential_geodes <= $best_sequence.geodes
    return [] if potential_geodes == 0

    [nil,0,1,2,3].map do |next_choice|
      next_sequence(next_choice)
    end.compact
  end

  def length
    @sequence.length
  end

  def weight
    @weight ||= @sequence.map { |choice| choice || 0 }.join
  end

  def <=>(other)
    return 0 if self == other
    
    res = self.weight <=> other.weight
    res = self.length <=> other.length if res == 0

    -res
  end

  def potential_geodes
    @resources[:geode] + 
      (@bots[:geode] * (MINUTES - @sequence.length)) + 
      (0..[MINUTES - 1 - @sequence.length,0].max).inject(:+)
  end
end

MINUTES = 24

blueprints = File.readlines('day19_sample.txt').map {|l| Blueprint.from_line(l) }

sum_quality_level = blueprints[1..1].map do |blueprint|
  sequence = Sequence.new(blueprint, {ore: 1, clay: 0, obsidian: 0, geode: 0}, {ore: 0, clay: 0, obsidian: 0, geode: 0}, [])
  $best_sequence = sequence
  sequence_to_try = SortedSet.new([sequence])
  
  i = 0
  while sequence_to_try.any?
    sequence = sequence_to_try.first
    sequence_to_try.delete(sequence)
  
    # mark it as possible if it's the right length
    if sequence.length == MINUTES
      if $best_sequence.nil? || sequence.geodes > $best_sequence.geodes
        $best_sequence = sequence 
      end
      # next
    end
  
    # add next sequences to the list
    next_sequences = sequence.next_sequences

    sequence_to_try += next_sequences

    puts "\n================= it: #{i} , best: #{$best_sequence.geodes}====================" 
    puts "\texploring sequence: #{sequence}"
    puts "\t\tnext sequences:\n\t\t\t#{next_sequences.map(&:to_s).join("\n\t\t\t")}"

    i += 1
  end  

  puts "finished blueprint #{blueprint.id} in #{i} iterations, best: #{$best_sequence.geodes}"
  blueprint.id * $best_sequence.geodes
end.sum

puts "sum_quality_level: #{sum_quality_level}"