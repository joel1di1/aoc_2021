# frozen_string_literal: true

def discover_travels(city, current_travel:, travels:)
  @cities[city].each do |next_city, distance|
    next if current_travel.include?(next_city)

    next_travel = "#{current_travel} -> #{next_city}"
    travels[next_travel] = (travels[current_travel] || 0) + distance
    discover_travels(next_city, current_travel: next_travel, travels: travels)
  end
end

@cities = {}

File.readlines('day9.txt').map(&:strip).each do |line|
  city, other_city, distance = line.match(/(\w+) to (\w+) = (\d+)/).captures
  distance = distance.to_i

  @cities[city] ||= {}
  @cities[other_city] ||= {}
  @cities[city][other_city] = distance
  @cities[other_city][city] = distance
end

travels = {}

@cities.each_key do |start|
  discover_travels(start, current_travel: start, travels: travels)
end

min_distance = 10_000
max_distance = 0
travels.each do |travel, distance|
  next if travel.scan(/->/).count < @cities.count - 1

  min_distance = distance if distance < min_distance
  max_distance = distance if distance > max_distance
end

puts "part1 : #{min_distance}"
puts "part1 : #{max_distance}"
