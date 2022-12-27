# frozen_string_literal: true

require 'readline'
require 'byebug'
require 'set'

def assert_eq(expected, actual, msg: nil)
  raise "Expected #{expected} but received #{actual}" if expected != actual
end

def assert(actual, msg: nil)
  msg ||= "Expected truthy but received #{actual}"
  raise msg unless actual
end

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

class Heap
  def initialize
    @heap = []
  end

  def push(element)
    @heap << element
    bubble_up(@heap.length - 1)
  end

  def <<(element)
    push(element)
  end

  def pop
    swap(0, @heap.length - 1)
    min = @heap.pop
    bubble_down(0)
    min
  end

  def peek
    @heap[0]
  end

  def empty?
    @heap.empty?
  end

  def size
    @heap.size
  end

  private

  def bubble_up(index)
    parent_index = parent_index(index)
    return if index == 0 || compare(@heap[parent_index], @heap[index])

    swap(index, parent_index)
    bubble_up(parent_index)
  end

  def bubble_down(index)
    left_child_index = left_child_index(index)
    right_child_index = right_child_index(index)
    return if left_child_index >= @heap.length

    if right_child_index >= @heap.length || compare(@heap[left_child_index], @heap[right_child_index])
      child_index = left_child_index
    else
      child_index = right_child_index
    end

    return if compare(@heap[index], @heap[child_index])

    swap(index, child_index)
    bubble_down(child_index)
  end

  def swap(index1, index2)
    @heap[index1], @heap[index2] = @heap[index2], @heap[index1]
  end

  def parent_index(index)
    (index - 1) / 2
  end

  def left_child_index(index)
    index * 2 + 1
  end

  def right_child_index(index)
    index * 2 + 2
  end
end

class MaxHeap < Heap
  def compare(a, b)
    a >= b
  end
end

class MinHeap < Heap
  def compare(a, b)
    a <= b
  end
end

class HeapElement
  attr_reader :value, :priority

  def initialize(value, priority)
    @value = value
    @priority = priority
  end

  def <=>(other)
    @priority <=> other.priority
  end

  def <=(other)
    @priority <= other.priority
  end

  def >=(other)
    @priority >= other.priority
  end
    
  def <(other)
    @priority < other.priority
  end

  def >(other)
    @priority > other.priority
  end
end

class PriorityQueue
  def initialize
    @min_heap = MinHeap.new
  end

  def push(element, priority)
    @min_heap << HeapElement.new(element, priority)
  end

  def pop
    element = @min_heap.pop
    [element.value, element.priority]
  end

  def empty?
    @min_heap.empty?
  end

  def size
    @min_heap.size
  end
end


# find the shortest path between two nodes in a graph
# Nodes must respond to #neighbors and #cost(neighbor)
def dijkstra(start_node, end_node, debug_every: nil)
  # Create a set to store the nodes that have been visited
  visited = Set.new

  # Create a priority queue to store the nodes that need to be processed
  # The priority queue will be sorted by the distance from the start node
  pq = PriorityQueue.new

  # Add the start node to the priority queue with a distance of 0
  pq.push(start_node, 0)

  # While there are nodes in the priority queue
  while !pq.empty?
    # Get the node with the smallest distance from the priority queue
    current_node, distance = pq.pop

    # If the current node is the end node, return the distance
    return distance if current_node == end_node

    # Mark the current node as visited
    visited.add(current_node)

    # For each neighbor of the current node
    debugger if current_node.is_a?(String)
    current_node.neighbors.each do |neighbor|
      # If the neighbor has not been visited
      if !visited.include?(neighbor)
        # Calculate the distance to the neighbor as the distance to the current node plus the cost of the edge between the current node and the neighbor
        neighbor_distance = distance + current_node.cost(neighbor)

        # Add the neighbor to the priority queue with the calculated distance
        debugger if neighbor.is_a?(String)
        pq.push(neighbor, neighbor_distance)
      end
    end
  end

  # If the end node was not reached, return nil
  nil
end

class PriorityQueue
  def initialize
    @min_heap = MinHeap.new
  end

  def push(element, priority)
    @min_heap << HeapElement.new(element, priority)
  end

  def pop
    element = @min_heap.pop
    [element.value, element.priority]
  end

  def empty?
    @min_heap.empty?
  end
end
