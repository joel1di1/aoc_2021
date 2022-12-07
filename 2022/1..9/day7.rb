# frozen_string_literal: true

require 'byebug'
require 'set'

# file
class MyFile
  attr_reader :name, :size

  def initialize(name, size)
    @name = name
    @size = size.to_i
  end
end

# directory
class MyDir
  def initialize(name, parent)
    @dirs = {}
    @files = {}
    @name = name
    @parent = parent
  end

  def <<(file_or_dir)
    if file_or_dir.instance_of?(MyDir)
      @dirs[file_or_dir.name] = file_or_dir
    else
      @files[file_or_dir.name] = file_or_dir
    end
  end

  def cd(dir_name)
    return @parent if dir_name == '..'
    return ROOT if dir_name == '/'

    @dirs[dir_name] ||= MyDir.new(dir_name, self)
  end

  def all_dirs(all = Set.new)
    all << self
    @dirs.each_value { |dir| dir.all_dirs(all) }
    all
  end

  def size
    @size ||= compute_size
  end

  def compute_size
    @dirs.values.map(&:size).sum + @files.values.map(&:size).sum
  end
end

lines = File.readlines('day7.txt')

ROOT = MyDir.new('', nil)
@current_dir = ROOT

lines.map(&:strip).each do |line|
  case line
  when /\$ cd (.*)/
    @current_dir = @current_dir.cd(Regexp.last_match(1))
  when /(\d+) (\S+)/
    @current_dir << MyFile.new(Regexp.last_match(2), Regexp.last_match(1).to_i)
  end
end

all_dirs = ROOT.all_dirs

puts "part 1: #{all_dirs.select { |dir| dir.size <= 100_000 }.map(&:size).sum}"

total_available = 70_000_000
needed_free_space = 30_000_000

total_used_space = ROOT.size

new_space_needed = needed_free_space - (total_available - total_used_space)

puts "part 2: #{all_dirs.select { |dir| dir.size > new_space_needed }.min_by(&:size).size}"
