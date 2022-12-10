
require 'byebug'

preferrences = {}

File.readlines('day13.txt').each do |line|
  line = line.gsub('lose ', '-')
  capts = /(?<guest>\w+) would (\w+\s)?(?<num>-?\d+) happiness units by sitting next to (?<other>\w+)./.match(line)
  debugger if capts.nil?
  guest = preferrences[capts[:guest]] ||= {}
  guest[capts[:other]] = capts[:num].to_i
end

guests = preferrences.keys

max_happiness = 0
best_config = nil

# list all possible permutation of an array
def permutations(array)
  return [array] if array.size <= 1
  perms = []
  array.each_with_index do |el, i|
    perms += permutations(array[0...i] + array[i+1..-1]).map do |perm|
      [el] + perm
    end
  end
  perms
end

def happiness(arrangement, preferrences)
  arrangement.map.with_index do |guest, i|
    preferrences[guest][arrangement[i-1]] + preferrences[guest][arrangement[(i+1) % arrangement.size]]
  end.sum
end

puts permutations(guests).map{ |arrangement| happiness(arrangement, preferrences) }.max

me = "BLA"
preferrences[me] = {}
guests.each do |guest|
  preferrences[guest][me] = 0
  preferrences[me][guest] = 0
end

guests << me
puts permutations(guests).map{ |arrangement| happiness(arrangement, preferrences) }.max
