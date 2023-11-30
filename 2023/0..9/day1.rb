# frozen_string_literal: true

class AStar
  def initialize(start, goal)
    @start = start
    @goal = goal
  end

  def find_path
    open_set = [@start]
    came_from = {}
    g_score = Hash.new(Float::INFINITY)
    g_score[@start] = 0
    f_score = Hash.new(Float::INFINITY)
    f_score[@start] = heuristic_cost_estimate(@start)

    until open_set.empty?
      current = open_set.min_by { |node| f_score[node] }
      return reconstruct_path(came_from, current) if current == @goal

      open_set.delete(current)

      neighbors(current).each do |neighbor|
        tentative_g_score = g_score[current] + distance_between(current, neighbor)

        next unless tentative_g_score < g_score[neighbor]

        came_from[neighbor] = current
        g_score[neighbor] = tentative_g_score
        f_score[neighbor] = g_score[neighbor] + heuristic_cost_estimate(neighbor)

        open_set << neighbor unless open_set.include?(neighbor)
      end
    end
  end

  private

  def heuristic_cost_estimate(node)
    # TODO: Implement your own heuristic function here
    # This function should estimate the cost from the given node to the goal
    # It should return a numeric value
  end

  def distance_between(node1, node2)
    # TODO: Implement your own distance function here
    # This function should calculate the distance between the given nodes
    # It should return a numeric value
  end

  def neighbors(node)
    # TODO: Implement your own function to get the neighbors of the given node
    # This function should return an array of neighboring nodes
  end

  def reconstruct_path(came_from, current)
    path = [current]
    while came_from.key?(current)
      current = came_from[current]
      path.unshift(current)
    end
    path
  end
end
