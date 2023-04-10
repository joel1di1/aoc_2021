# frozen_string_literal: true

require 'byebug'

def scenic_score(tree_map, row, col)
  tree_height = tree_map[row][col]
  rows = tree_map.size
  columns = tree_map[0].size

    # First, check if the tree is located at the top row (row == 0). If it is, the "up" score should be 0 because there's no tree above it.
    # Otherwise, traverse the rows above the current tree in reverse order (from row-1 to 0) and find the index of the first row where the height of the tree is greater than or equal to the height of the current tree.
    # The "up" score is the difference between the current row and the found index (if any). If no such row is found, the "up" score is equal to the current row.
    up = row
    (row - 1).downto(0) do |r|
        if tree_map[r][col] >= tree_height
            up = row - r
            break
        end
    end

    # Similarly, check if the tree is located at the bottom row (row == rows - 1). If it is, the "down" score should be 0 because there's no tree below it.
    # Otherwise, traverse the rows below the current tree in order (from row+1 to rows-1) and find the index of the first row where the height of the tree is greater than or equal to the height of the current tree.
    # The "down" score is the difference between the found index and the current row (if any). If no such row is found, the "down" score is equal to the number of rows minus the current row.
    down = rows - row - 1
    (row + 1).upto(rows - 1) do |r|
        if tree_map[r][col] >= tree_height
            down = r - row
            break
        end
    end

    # Similarly, check if the tree is located at the leftmost column (col == 0). If it is, the "left" score should be 0 because there's no tree to the left of it.
    # Otherwise, traverse the columns to the left of the current tree in reverse order (from col-1 to 0) and find the index of the first column where the height of the tree is greater than or equal to the height of the current tree.
    # The "left" score is the difference between the current column and the found index (if any). If no such column is found, the "left" score is equal to the current column.
    left = col
    (col - 1).downto(0) do |c|
        if tree_map[row][c] >= tree_height
            left = col - c
            break
        end
    end

    # Similarly, check if the tree is located at the rightmost column (col == columns - 1). If it is, the "right" score should be 0 because there's no tree to the right of it.
    # Otherwise, traverse the columns to the right of the current tree in order (from col+1 to columns-1) and find the index of the first column where the height of the tree is greater than or equal to the height of the current tree.
    # The "right" score is the difference between the found index and the current column (if any). If no such column is found, the "right" score is equal to the number of columns minus the current column.
    right = columns - col - 1
    (col + 1).upto(columns - 1) do |c|
        if tree_map[row][c] >= tree_height
            right = c - col
            break
        end
    end

    up * down * left * right
end

  
  def highest_scenic_score(tree_map)
    rows = tree_map.size
    columns = tree_map[0].size
  
    max_scenic_score = 0
  
    (0...rows).each do |row|
      (0...columns).each do |col|
        score = scenic_score(tree_map, row, col)
        max_scenic_score = [max_scenic_score, score].max
      end
    end
  
    max_scenic_score
  end
  
  input_file = File.read('day8.txt')
  tree_map = input_file.lines.map { |line| line.chomp.chars.map(&:to_i) }
  
  puts highest_scenic_score(tree_map)
  