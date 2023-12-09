class Map
  attr_accessor :directions, :nodes

  def initialize
    @directions = []
    @nodes = {}
  end

  def starting_nodes
    @nodes.values.select(&:starting_node?)
  end

  def steps
    l_steps = starting_nodes.map { |node| node.steps(@directions) }
    puts "steps: #{l_steps}"
    l_steps.reduce { |lcm, count| lcm.lcm(count) }
  end
end

class Node
  attr_accessor :name, :left, :right

  def initialize(name)
    @name = name
  end

  def starting_node?
    @name[-1] == 'A'
  end

  def ending_node?
    @name[-1] == 'Z'
  end

  def follow(direction)
    direction == 'L' ? left : right
  end

  def steps(directions)
    steps = 0
    curr = self
    iterator = directions.cycle
    until curr.ending_node?
      steps += 1
      curr = curr.follow(iterator.next)
    end
    steps
  end

  def inspect
    "#{@name} (#{@left.try(&:name)}, #{@right.try(&:name)})"
  end
end

map = Map.new

lines = File.readlines("#{__dir__}/input8.txt", chomp: true)
map.directions = lines.first.chars

lines[2..].each do |line|
  name, left, right = line.split(/\W+/)

  map.nodes[name] ||= Node.new(name)
  map.nodes[left] ||= Node.new(left)
  map.nodes[right] ||= Node.new(right)

  map.nodes[name].left = map.nodes[left]
  map.nodes[name].right = map.nodes[right]
end

puts map.steps
