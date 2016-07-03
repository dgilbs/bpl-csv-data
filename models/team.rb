require 'pry'
require 'json'

class Team

  attr_accessor :name
  @@all = []

  def initialize(name)
    @name = name
    @@all<<self
  end

  def self.all
    @@all 
  end

  def self.all_names
    self.all.map{|t| t.name}
  end

  def self.find(name)
    self.all.select{|t| t.name == name}[0]
  end

  def games
    Game.all.select{|g| g.teams.include?(self.name)}
  end

  def games_won
    Game.all.select{|g| g.teams.include?(self.name) && g.winner == self.name}
  end

  def games_lost
    Game.all.select{|g| g.teams.include?(self.name) && g.loser == self.name}
  end

  def games_drawn
    Game.all.select{|g| g.teams.include?(self.name) && g.draw?}
  end

  def record
    hash ={}
    hash["wins"] = self.games_won.length
    hash["draws"] = self.games_drawn.length
    hash["losses"] = self.games_lost.length
    hash
  end

  def points 
    count = 0
    self.record.each do |k, v|
      count += 3 * v if k =="wins"
      count += 1 * v if k == "draws"
    end
    count
  end

  def self.table
    hash = {}
    self.all.each do |team|
      hash[team] = team.points
    end
    arr = hash.sort_by{|k, v| v}.reverse
    hash = {}
    arr.each do |team|
      hash[team[0]] = team[1]
    end
    hash
  end

end