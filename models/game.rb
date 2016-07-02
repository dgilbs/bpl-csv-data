require 'pry'
require 'json'


class Game

  attr_accessor :date, :home_team, :away_team, :home_goals, :away_goals, :referee

  @@all = []

  def initialize(hash)
    @home_team = hash["HomeTeam"]
    @away_team = hash["AwayTeam"]
    @home_goals = hash["FTHG"].to_i
    @away_goals = hash["FTAG"].to_i
    @referee = hash["Referee"]
    date_elements = hash["Date"].split("/")
    @date = Date.new(date_elements[2].to_i + 2000, date_elements[1].to_i, date_elements[0].to_i)
    @@all << self
  end

  def self.all
    @@all
  end

  def draw?
    self.home_goals == self.away_goals
  end

  def winner
    if self.home_goals > self.away_goals
      self.home_team
    elsif self.away_goals > self.home_goals
      self.away_team
    else
      nil
    end  
  end

  def score
    score_hash = {}
    score_hash[self.home_team] = self.home_goals
    score_hash[self.away_team] = self.away_goals
    score_hash
  end




end