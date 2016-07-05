require 'pry'
require 'json'


class Game

  attr_accessor :date, :home_team, :away_team, :home_goals, :away_goals, :referee
  attr_accessor :home_halftime_goals, :away_halftime_goals, :result, :half_time_result
  attr_accessor :home_team_shots, :away_team_shots, :homes_team_sot, :away_team_sot
  attr_accessor :home_team_post, :away_team_post, :home_team_corners, :away_team_corners
  attr_accessor :home_team_fouls, :away_team_fouls, :home_team_offsides, :away_team_offsides
  attr_accessor :home_team_yellows, :away_team_yellows, :home_team_reds, :away_team_reds

  @@all = []

#   HHW = Home Team Hit Woodwork
# AHW = Away Team Hit Woodwork
# HC = Home Team Corners
# AC = Away Team Corners
# HF = Home Team Fouls Committed
# AF = Away Team Fouls Committed
# HO = Home Team Offsides
# AO = Away Team Offsides
# HY = Home Team Yellow Cards
# AY = Away Team Yellow Cards
# HR = Home Team Red Cards
# AR = Away Team Red Cards

  def initialize(hash)
    @home_team = hash["HomeTeam"]
    @away_team = hash["AwayTeam"]
    @home_goals = hash["FTHG"].to_i
    @away_goals = hash["FTAG"].to_i
    @home_halftime_goals = hash["HTHG"].to_i
    @away_halftime_goals = hash["HTAG"].to_i
    @result = hash["FTR"]
    @half_time_result = hash["HTR"]
    @home_team_shots = hash["HS"].to_i
    @away_team_shots = hash["AS"].to_i
    @homes_team_sot = hash["HST"].to_i
    @away_team_shots = hash["AST"].to_i
    @home_team_post = hash["HHW"].to_i
    @away_team_post = hash["AHW"].to_i
    @home_team_corners = hash["HC"].to_i
    @away_team_corners = hash["AC"].to_i
    @home_team_fouls = hash["HF"].to_i 
    @away_team_fouls = hash["AF"].to_i
    @home_team_offsides = hash["HO"].to_i
    @away_team_offsides = hash["AO"].to_i 
    @home_team_yellows = hash["HY"].to_i 
    @away_team_yellows = hash["AY"].to_i
    @home_team_reds = hash["HR"].to_i
    @away_team_reds = hash["AR"].to_i
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

  def home_win?
    self.result == "H"
  end

  def away_win?
    self.result == "A"
  end

  def self.team_matchups(team_one, team_two)
    self.all.select{|g| g.teams.include?(team_one) && g.teams.include?(team_two)}
  end

  def red_card_win
    self.winner == self.home_team && self.home_team_reds > 0 || self.winner == self.away_team && self.away_team_reds > 0
  end

  def self.before_date(day)
    self.all.select{|g| g.date < day}
  end

  def goals
    self.home_goals + self.away_goals
  end




end