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

def count_paths_basic(graph, start_node)
  memo = {}

  count = lambda do |node|
    return 1 if node == "out"
    return memo[node] if memo.key?(node)

    total = graph[node].sum { |child| count.call(child) }
    memo[node] = total
  end

  return 0 unless graph.key?(start_node)

  count.call(start_node)
end

def count_paths_with_devices(graph, start_node, must_visit)
  memo = {}

  count = lambda do |node, visited|
    return visited.all? ? 1 : 0 if node == "out"

    key = [node, visited]
    return memo[key] if memo.key?(key)

    total = 0
    graph[node].each do |child|
      next_visited = visited.dup
      must_visit.each_with_index do |device, index|
        next_visited[index] ||= (child == device)
      end
      total += count.call(child, next_visited)
    end

    memo[key] = total
  end

  return 0 unless graph.key?(start_node)

  initial_visited = must_visit.map { |device| start_node == device }
  count.call(start_node, initial_visited)
end

puts "part 1 : #{count_paths_basic(graph, 'you')}"
puts "part 2 : #{count_paths_with_devices(graph, 'svr', ['dac', 'fft'])}"
