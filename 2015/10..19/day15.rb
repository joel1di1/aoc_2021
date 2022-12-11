# frozen_string_literal: true

require 'byebug'
require 'json'

ingredients = JSON.parse(File.read('day15.txt'))
ingredient_names = ingredients.keys

recipes = []

(0..100).map do |i|
  (0..100 - i).map do |j|
    (0..100 - i - j).map do |k|
      l = 100 - i - j - k
      recipes << [i, j, k, l]
    end
  end
end

properties_values = recipes.map do |recipe|
  ingredient_names.map do |ingredient|
    ingredients[ingredient].map do |_property, value|
      value * recipe[ingredient_names.index(ingredient)]
    end
  end
end

summed = properties_values.map do |recipe|
  recipe.transpose.map do |property|
    [property.sum, 0].max
  end
end

puts "Part1: #{summed.map { |recipe| recipe[0..3].reduce(:*) }.max}"

puts "Part1: #{summed.select { |recipe| recipe[4] == 500 }.map { |recipe| recipe[0..3].reduce(:*) }.max}"
