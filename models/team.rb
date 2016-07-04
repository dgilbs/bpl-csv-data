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

  def home_games
    self.games.select{|g| g.home_team == self.name}
  end

  def away_games
    self.games.select{|g| g.away_team == self.name}
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

  def home_wins
    self.games_won.select{|g| g.home_team == self.name}
  end

  def home_losses
    self.games_lost.select{|g| g.home_team == self.name}
  end

  def home_draws
    self.games_drawn.select{|g| g.home_team == self.name}
  end

  def home_record
    {"wins"=> self.home_wins.count, "draws"=> self.home_draws.count, "losses"=> self.home_losses.count}
  end

  def home_points
    count = 0
    self.home_record.each do |k, v|
      count += 3 * v if k =="wins"
      count += 1 * v if k == "draws"
    end
    count
  end

  def self.home_table
    hash = {}
    self.all.each do |team|
      hash[team] = team.home_points
    end
    arr = hash.sort_by{|k, v| v}.reverse
    hash = {}
    arr.each do |team|
      hash[team[0]] = team[1]
    end
    hash
  end

  def goals_scored
    arr = self.games.map{|g| g.score}
    arr = arr.map{|h| h[self.name]}
    arr.inject(0){|sum, goals| sum + goals}
  end

  def home_goals
    arr = self.home_games.map{|g| g.home_goals}
    arr.inject(0){|sum, goal| sum + goal}
  end

  def away_goals
    arr = self.away_games.map{|g| g.away_goals}
    arr.inject(0){|sum, goal| sum + goal}
  end

  def self.more_away_goals
    self.all.select{|t| t.away_goals > t.home_goals}
  end



end