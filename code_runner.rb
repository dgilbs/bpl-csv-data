require_relative 'environment.rb'
require 'pry'
require 'json'


CSV.foreach("data/2015_season.csv", headers: true) do |row|
  g = Game.new(row)
  
end

Game.all.first.score

binding.pry

arr =[]