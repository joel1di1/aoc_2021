# frozen_string_literal: true

def update_tail(head, tail)
    if tail == head
      # if the tail and head are at the same position, they overlap and stay there
      tail
    elsif tail[0] == head[0]
      # if the tail and head are in the same column, move the tail one row towards the head
      [tail[0], tail[1] < head[1] ? tail[1] + 1 : tail[1] - 1]
    elsif tail[1] == head[1]
      # if the tail and head are in the same row, move the tail one column towards the head
      [tail[0] < head[0] ? tail[0] + 1 : tail[0] - 1, tail[1]]
    else
      # otherwise, move the tail one row and one column towards the head (diagonally)
      [tail[0] < head[0] ? tail[0] + 1 : tail[0] - 1, tail[1] < head[1] ? tail[1] + 1 : tail[1] - 1]
    end
  end
  
  def count_visited_positions(motions)
    head = [0, 0] # starting position
    tail = [0, 0] # starting position, overlapping with head
    visited = { [0, 0] => true } # mark starting position as visited
  
    motions.each do |motion|
      # update head position for the specified number of steps in the specified direction
      case motion[0]
      when 'U'
        motion[1].times do
          head = [head[0] - 1, head[1]]
          # update tail position if head and tail are not adjacent
          while (head[0] - tail[0]).abs + (head[1] - tail[1]).abs > 1
            tail = update_tail(head, tail)
            visited[tail] = true
          end
          # mark head position as visited
          visited[head] = true
        end
      when 'D'
        motion[1].times do
          head = [head[0] + 1, head[1]]
          # update tail position if head and tail are not adjacent
          while (head[0] - tail[0]).abs + (head[1] - tail[1]).abs > 1
            tail = update_tail(head, tail)
            visited[tail] = true
          end
          # mark head position as visited
          visited[head] = true
        end
      when 'L'
        motion[1].times do
          head = [head[0], head[1] - 1]
          # update tail position if head and tail are not adjacent
          while (head[0] - tail[0]).abs + (head[1] - tail[1]).abs > 1
            tail = update_tail(head, tail)
            visited[tail] = true
          end
          # mark head position as visited
          visited[head] = true
        end
    when 'R'
        motion[1].times do
          head = [head[0], head[1] + 1]
          # update tail position if head and tail are not adjacent
          while (head[0] - tail[0]).abs + (head[1] - tail[1]).abs > 1
            tail = update_tail(head, tail)
            visited[tail] = true
          end
          # mark head position as visited
          visited[head] = true
        end
      end
    end
  
    visited.size
  end
  
  # read input from file
  motions = File.readlines('day9.txt').map { |m| [m[0], m[2..-1].to_i] }
    
  # count visited positions
  puts count_visited_positions(motions)
  