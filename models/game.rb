require 'pry'
require 'json'


class Game
  attr_accessor :home_team, :away_team,:score, :halftime_score, :shot_count, :sot_count, :post_count
  attr_accessor :corners, :fouls, :offsides, :red_cards, :yellow_cards, :half_time_result, :result, :date, :referee

  @@all = []

  def initialize(hash)
    @home_team = hash["HomeTeam"]
    @away_team = hash["AwayTeam"]
    @score = {self.home_team => hash["FTHG"].to_i,
      self.away_team => hash["FTAG"].to_i}
    @halftime_score = {self.home_team => hash["HTHG"].to_i, 
      self.away_team => hash["HTAG"].to_i}
    @result = hash["FTR"]
    @half_time_result = hash["HTR"]
    @shot_count = {self.home_team => hash["HS"].to_i,
      self.away_team => hash["AS"].to_i}
    @sot_count = {self.home_team => hash["HST"].to_i,
      self.away_team => hash["AST"].to_i}
    @post_count = {self.home_team => hash["HHW"].to_i,
      self.away_team => hash["AHW"].to_i}
    @corners = {self.home_team => hash["HC"].to_i,
      self.away_team => hash["AC"].to_i}
    @fouls = {self.home_team => hash["HF"].to_i ,
      self.away_team => hash["AF"].to_i}
    @offsides = {self.home_team => hash["HO"].to_i,
      self.away_team => hash["AO"].to_i}
    @yellow_cards =  {self.home_team => hash["HY"].to_i,
      self.away_team => hash["AY"].to_i}
    @red_cards = {self.home_team => hash["HR"].to_i,
      self.away_team => hash["AR"].to_i}
    @referee = hash["Referee"]
    date_elements = hash["Date"].split("/")
    @date = Date.new(date_elements[2].to_i + 2000, date_elements[1].to_i, date_elements[0].to_i)
    @@all << self
  end

  def self.all
    @@all
  end

  def draw?
    self.score[self.away_team] == self.score[self.home_team]
  end

  def winner
    if self.score[self.home_team] > self.score[self.away_team]
      self.home_team
    elsif self.score[self.away_team] > self.score[self.home_team]
      self.away_team
    else
      nil
    end  
  end

  def loser
    if self.score[self.home_team] < self.score[self.away_team]
      self.home_team
    elsif self.score[self.away_team] < self.score[self.home_team]
      self.away_team
    else
      nil
    end  
  end

  def goal_difference
    if self.winner
      self.score[self.winner] - self.score[self.loser]
    else
      0
    end
  end

  def teams
    [self.home_team, self.away_team]
  end

  def refs
    @refs
  end

  def self.games_by_team(team)
    games = self.all.select{|game| game.teams.include?(team)}
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
    self.red_cards[self.winner] > 0 if self.winner
  end

  def self.before_date(day)
    self.all.select{|g| g.date < day}
  end

  def goals
    self.score[self.home_team] + self.score[self.away_team]
  end

  def second_half_score
    {self.home_team => (self.score[self.home_team] - self.halftime_score[self.home_team]),
      self.away_team => (self.score[self.away_team] - self.halftime_score[self.away_team])
    }
  end

  def halftime_leader
    return self.away_team if self.half_time_result == "A"
    return self.home_team if self.half_time_result == "H"
    return nil if self.half_time_result == "D"
  end

  def comeback?
    return true if self.half_time_result == "H" && self.result == "A"
    return true if self.half_time_result == "A" && self.result == "H"
    return false
  end

  def self.comebacks
    self.all.select{|g| g.comeback?}
  end

  def halftime_tie_broken
    self.half_time_result == "D" && self.result != "D"
  end

  def self.halftime_ties_broken
    self.all.select{|g| g.halftime_tie_broken}
  end

  def shutout
    self.score[self.home_team]== 0 || self.score[self.away_team] ==0
  end

  def more_shots
    return self.away_team if self.shot_count[self.away_team] > self.shot_count[self.home_team]
    return self.home_team if self.shot_count[self.home_team] > self.shot_count[self.away_team]
    return "tie"
  end

  def more_shots_and_lost
    self.more_shots == self.loser
  end

  def both_teams_red_carded
    self.red_cards[self.home_team] > 0 && self.red_cards[self.away_team] > 0
  end

  def total_red_cards
    self.red_cards[self.home_team] + self.red_cards[self.away_team]
  end

  def sot_percentage_per_team
    home_count= (self.sot_count[self.home_team].to_f/self.shot_count[self.home_team].to_f).round(4)
    away_count = (self.sot_count[self.away_team].to_f/self.shot_count[self.away_team].to_f).round(4)
    {self.home_team => home_count, self.away_team => away_count}
  end

  def shot_conversion_per_team
    home_count = (self.score[self.home_team].to_f/self.shot_count[self.home_team].to_f).round(4)
    away_count = (self.score[self.away_team].to_f/self.shot_count[self.away_team].to_f).round(4)
    {self.home_team => home_count, self.away_team => away_count}
  end

  def total_fouls
    self.fouls.values.inject(0, :+)
  end



end