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

  def self.all_teams
    self.all.map{|g| g.home_team}.uniq
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

  def loser
    if self.home_goals < self.away_goals
      self.home_team
    elsif self.away_goals < self.home_goals
      self.away_team
    else
      nil
    end  
  end


  def teams
    arr = []
    arr.push(self.home_team)
    arr.push(self.away_team)
    arr
  end

  def score
    score_hash = {}
    score_hash[self.home_team] = self.home_goals
    score_hash[self.away_team] = self.away_goals
    score_hash
  end

  def self.games_by_team(team)
    games = self.all.select{|game| game.teams.include?(team)}
  end

  def self.wins_by_team(team)
    games = self.games_by_team(team)
    games.select{|g| g.winner == team}.length
  end

  def self.losses_by_team(team)
    games = self.games_by_team(team)
    games.select{|g| g.loser == team}.length
  end

  def self.draws_by_team(team)
    games = self.games_by_team(team)
    games.select{|g| g.draw?}.length
  end

  def self.team_record(team)
    record = {}
    record["wins"] = self.wins_by_team(team)
    record["losses"] = self.losses_by_team(team)
    record["draws"] = self.draws_by_team(team)
    record
  end

  def self.team_points(team)
    total = 0
    record = self.team_record(team)
    record.each do |category, count|
      total += 3 * count if category == "wins"
      total += 1 * count if category == "draws"
    end
    total
  end

  def self.table
    hash = {}
    self.all_teams.each do |team|
      hash[team] = self.team_points(team)
    end
    arr = hash.sort_by{|k, v| v}.reverse
    hash = {}
    arr.each do |team|
      hash[team[0]] = team[1]
    end
    hash
  end

  def self.team_matchup(team_one, team_two)
    self.all.select{|g| g.teams.include?(team_one) && g.teams.include?(team_two)}
  end




end