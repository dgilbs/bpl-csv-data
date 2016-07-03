require_relative 'environment.rb'
require 'pry'
require 'json'


CSV.foreach("data/2015_season.csv", headers: true) do |row|
  g = Game.new(row)
  t1 = Team.new(row["HomeTeam"]) if !Team.all_names.include?(row["HomeTeam"])
  t2 = Team.new(row["AwayTeam"]) if !Team.all_names.include?(row["AwayTeam"])
  
end

x = Game.team_record("Arsenal")

binding.pry

arr =[]