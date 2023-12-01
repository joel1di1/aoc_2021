# frozen_string_literal: true

require 'byebug'
require 'set'
require_relative '../../fwk'

input = File.readlines('day19.txt');

replacements = []
original_molecule = nil

input.each do |line|
  next if line.empty?

  case line
  when /(.*)\=>(.*)/
    key = Regexp.last_match(1).strip
    replacement = Regexp.last_match(2).strip
    replacements << [key, replacement]
  when /.+/
    original_molecule = line.strip
  end
end

replacements = replacements.freeze

def generate_molecules_with_one_replacement(original_molecule, replacement)
  key = replacement[0]
  value = replacement[1]
  new_molecules = []
  (0..original_molecule.length-1).each do |i|
    if original_molecule[i..].start_with?(key)
      new_molecules << original_molecule[0, i] + value + original_molecule[i+key.length..]
    end
  end

  new_molecules
end

def generate_molecules_one_step(original_molecule, replacements)
  replacements.map do |replacement|
    generate_molecules_with_one_replacement(original_molecule, replacement)
  end.flatten.uniq
end

assert_eq(['A'], generate_molecules_with_one_replacement('B', ['B', 'A']))

one_step = generate_molecules_one_step(original_molecule, replacements)

puts "part1: #{one_step.count}"


# start with e
# molecules = ['e']
# step = 0
# molecules_old = Set.new

# until molecules.include?(original_molecule) || step > 10000
#   step += 1
#   puts "step #{step}"
#   puts "molecules: #{molecules}"

#   molecules.reject!{ |mol| mol.length > original_molecule.length }

#   molecules.each { |mol| molecules_old << mol }

#   molecules = molecules.map{ |mol| generate_molecules_one_step(mol, replacements) }.flatten.uniq
#   puts "mols #{molecules.count}"
# end

# puts "part2: #{step}"

class MinHeapStringLenght < Heap
  def compare(a, b)
    a.length <= b.length
  end
end

replacements_reversed = replacements.map { |a, b| [b, a] }

def findStepToE(molecule, replacements)
  heap = MinHeapStringLenght.new
  heap << molecule

  step = 0
  until heap.empty?
    mol = heap.pop
    break if mol == 'e'

    new_mols = generate_molecules_one_step(mol, replacements).flatten.uniq
    new_mols.each { |new_mol| heap << new_mol }

    step += 1
  end

  step
end

assert_eq(0, findStepToE('e', replacements_reversed))
assert_eq(1, findStepToE('HF', replacements_reversed))
assert_eq(2, findStepToE('OBF', replacements_reversed))

puts "part2: #{findStepToE(original_molecule, replacements_reversed)}"
