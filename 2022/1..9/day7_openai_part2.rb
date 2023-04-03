def find_smallest_directory_to_delete(node, required_space, current_space)
    return nil unless node
  
    directory_to_delete = nil
    if !node.children.empty? && (current_space + node.total_size >= required_space)
      directory_to_delete = node
    end
  
    node.children.values.each do |child|
      child_directory_to_delete = find_smallest_directory_to_delete(child, required_space, current_space)
      if child_directory_to_delete && (!directory_to_delete || child_directory_to_delete.total_size < directory_to_delete.total_size)
        directory_to_delete = child_directory_to_delete
      end
    end
  
    directory_to_delete
  end
  
  total_disk_space = 70_000_000
  used_space = root.total_size
  unused_space = total_disk_space - used_space
  required_space_for_update = 30_000_000
  additional_space_needed = required_space_for_update - unused_space
  
  smallest_directory_to_delete = find_smallest_directory_to_delete(root, used_space + additional_space_needed, 0)
  puts "The smallest directory to delete is '#{smallest_directory_to_delete.name}' with a total size of #{smallest_directory_to_delete.total_size}."
  