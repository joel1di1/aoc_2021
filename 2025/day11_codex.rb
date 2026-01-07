# frozen_string_literal: true

lines = File.readlines(File.join(__dir__, "input11.txt"), chomp: true)

graph = Hash.new { |h, k| h[k] = [] }
lines.each do |line|
  next if line.strip.empty?

  name, outputs = line.split(":", 2)
  name = name.strip
  outputs = outputs.to_s.split.map(&:strip)
  graph[name] = outputs
end

def count_basic_recursive(node, graph, memo)
  return 1 if node == "out"
  return memo[node] if memo.key?(node)

  total = graph[node].sum { |child| count_basic_recursive(child, graph, memo) }
  memo[node] = total
end

def count_paths_basic(graph, start_node)
  memo = {}
  return 0 unless graph.key?(start_node)

  count_basic_recursive(start_node, graph, memo)
end

def count_with_devices_recursive(node, visited, graph, must_visit, memo)
  return visited.all? ? 1 : 0 if node == "out"

  key = [node, visited]
  return memo[key] if memo.key?(key)

  total = 0
  graph[node].each do |child|
    next_visited = visited.dup
    must_visit.each_with_index do |device, index|
      next_visited[index] ||= (child == device)
    end
    total += count_with_devices_recursive(child, next_visited, graph, must_visit, memo)
  end

  memo[key] = total
end

def count_paths_with_devices(graph, start_node, must_visit)
  memo = {}
  return 0 unless graph.key?(start_node)

  initial_visited = must_visit.map { |device| start_node == device }
  count_with_devices_recursive(start_node, initial_visited, graph, must_visit, memo)
end

puts "part 1 : #{count_paths_basic(graph, 'you')}"
puts "part 2 : #{count_paths_with_devices(graph, 'svr', ['dac', 'fft'])}"


