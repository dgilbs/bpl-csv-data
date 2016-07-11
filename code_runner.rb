require_relative 'environment.rb'
require 'pry'
require 'json'


CSV.foreach("data/2015_season.csv", headers: true) do |row|
  g = Game.new(row)
  t1 = Team.new(row["HomeTeam"]) if !Team.all_names.include?(row["HomeTeam"])
  t2 = Team.new(row["AwayTeam"]) if !Team.all_names.include?(row["AwayTeam"])
  
end

x = Team.find("Arsenal")
y = Team.find("Man City")
z = Team.find("Aston Villa")

date = Date.new(2015,10,04)

g = Game.all[155]

t = x.most_sots_without_a_goal

binding.pry

arr =[]