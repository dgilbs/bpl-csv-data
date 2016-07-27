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
    {"wins" => self.games_won.length,
     "draws" => self.games_drawn.length,
     "losses" => self.games_lost.length}
  end

  def points_from_record(record)
    count = 0
    record.each do |k, v|
      count += v * 3 if k == "wins"
      count += v if k == "draws"
    end
    count
  end

  def points_dropped_from_record(record)
    count = 0
    record.each do |k, v|
      count += 3 * v if k == "losses"
      count += 2* v if k =="draws"
    end
    count
  end

  def self.table
    hash = {}
    self.all.each do |team|
      hash[team] = team.points_from_record(team.record)
    end
    arr = hash.sort_by{|k, v| v}.reverse
    hash = {}
    arr.each do |team|
      hash[team[0].name] = team[1]
    end
    hash
  end

  def self.table_sorter(hash)
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
      hash[team] = team.points_from_record(team.home_record)
    end
    arr = hash.sort_by{|k, v| v}.reverse
    hash = {}
    arr.each do |team|
      hash[team[0].name] = team[1]
    end
    hash
  end

  def goals_scored
    arr = self.games.map{|g| g.score}
    arr = arr.map{|h| h[self.name]}
    arr.inject(0){|sum, goals| sum + goals}
  end

  def goals_conceded
    final = []
    arr = self.games.map{|g| g.score}
    arr.each do |score|
      score.each do |k, v|
        final.push(v) if k != self.name
      end
    end
    final.inject(0, :+)
  end

  def home_goals
    arr = self.home_games.map{|g| g.score[self.name]}
    arr.inject(0){|sum, goal| sum + goal}
  end

  def away_goals
    arr = self.away_games.map{|g| g.score[self.name]}
    arr.inject(0){|sum, goal| sum + goal}
  end

  def self.teams_with_more_away_goals
    self.all.select{|t| t.away_goals > t.home_goals}
  end

  def away_wins
    self.games_won.select{|g| g.away_team == self.name}
  end

  def away_losses
    self.games_lost.select{|g| g.away_team == self.name}
  end

  def away_draws
    self.games_drawn.select{|g| g.away_team == self.name}
  end

  def away_record
    {"wins"=> self.away_wins.count, "draws"=> self.away_draws.count, "losses"=> self.away_losses.count}
  end

  def away_points
    count = 0
    self.away_record.each do |k, v|
      count += 3 * v if k =="wins"
      count += 1 * v if k == "draws"
    end
    count
  end

  def better_road_team
    self.away_points > self.home_points
  end

  def self.better_home_teams
    self.all.select{|t| !t.better_road_team}
  end

  def self.better_road_teams
    self.all.select{|t| t.better_road_team}
  end

  def self.away_table
    hash = {}
    self.all.each do |team|
      hash[team] = team.away_points
    end
    arr = hash.sort_by{|k, v| v}.reverse
    hash = {}
    arr.each do |team|
      hash[team[0].name] = team[1]
    end
    hash
  end

  def place
    arr = self.class.table.keys
    arr.index(self.name) + 1
  end

  def point_progression
    counter = 0
    hash = {"Week 0"=> 0}
    while counter < self.games.length
      old_string = "Week #{counter}"
      string = "Week #{counter + 1}"
      current = hash[old_string]
      hash[string] = current if self.games[counter].loser == self.name
      hash[string] = current + 3 if self.games[counter].winner == self.name
      hash[string] = current + 1 if self.games[counter].draw?
      counter += 1
    end
    hash
  end

  def self.table_at_week(number)
    string = "Week #{number}"
    hash = {}
    self.all.each do |team|
      hash[team.name] = {"points"=>team.point_progression[string], 
        "GD" => team.gd_at_week(number), "GS" => team.goals_scored_at_week(number)}
    end
    arr = hash.sort_by{|k,v| [v["points"], v["GD"], v["GS"]]}.reverse
    hash = {}
    arr.each do |team|
      hash[team[0]] = {"points" => team[1]["points"], "GD" => team[1]["GD"], "GS" => team[1]["GS"]}
    end
    hash
  end

  def place_at_week(number)
    arr = self.class.table_at_week(number).keys
    arr.index(self.name) + 1
  end

  def goals_scored_at_week(number)
    arr = self.games.map{|g| g.score}.map{|h| h[self.name]}.slice(0, number)
    arr.inject(0, :+)
  end

  def goals_conceded_at_week(number)
    arr = self.games.map{|g| g.score}.slice(0, number)
    final = []
    arr.each do |score|
      score.each do |k, v|
        final << v if k != self.name
      end
    end
    final.inject(0, :+)
  end

  def gd_at_week(number)
    self.goals_scored_at_week(number) - self.goals_conceded_at_week(number)
  end

  def table_progression
    hash = {}
    counter = 1
    while counter <= self.games.length
      hash[counter] = self.place_at_week(counter)
      counter += 1
    end
    hash
  end

  def games_at_date(date)
    Game.before_date(date).select{|g| g.teams.include?(self.name)}
  end

  def wins_at_date(date)
    self.games_at_date(date).select{|g| self.games_won.include?(g)}
  end

  def losses_at_date(date)
    self.games_at_date(date).select{|g| self.games_lost.include?(g)}
  end

  def draws_at_date(date)
    self.games_at_date(date).select{|g| self.games_drawn.include?(g)}
  end

  def record_at_date(date)
    {"wins" => self.wins_at_date(date).count, "draws"=> self.draws_at_date(date).count, "losses" => self.losses_at_date(date).count}
  end

  def points_at_date(date)
    counter = 0
    self.record_at_date(date).each do |k, v|
      counter += 3 * v if k =="wins"
      counter += 1 * v if k == "draws"
    end
    counter
  end

  def goals_scored_at_date(date)
    arr = self.games_at_date(date).map{|g| g.score[self.name]}
    arr.inject(0, :+)
  end

  def goals_conceded_at_date(date)
    arr = self.games_at_date(date).map{|g| g.goals}
    total = arr.inject(0, :+)
    total - self.goals_scored_at_date(date)
  end

  def gd_at_date(date)
    self.goals_scored_at_date(date) - self.goals_conceded_at_date(date)
  end

  def self.table_at_date(date)
    hash = {}
    self.all.each do |team|
      hash[team.name] = {"GP" => team.games_at_date(date).count, "points" => team.points_at_date(date), 
        "GD" => team.gd_at_date(date), "GS" => team.goals_scored_at_date(date)}
    end
    arr = hash.sort_by{|k, v| [v["points"], v["GD"], v["GS"]]}.reverse
    hash = {}
    arr.each do |team|
      hash[team[0]] = team[1]
    end
    hash
  end

  def place_at_date(date)
    arr = self.class.table_at_date(date).keys
    arr.index(self.name) + 1
  end

  def monthly_table_progression
    hash ={
      "September" => self.place_at_date(Date.new(2015, "09".to_i, 01)),
      "October" => self.place_at_date(Date.new(2015,10,01)),
      "November" => self.place_at_date(Date.new(2015,11,01)),
      "December" => self.place_at_date(Date.new(2015,12,01)),
      "January" => self.place_at_date(Date.new(2016,01,01)),
      "February" => self.place_at_date(Date.new(2016,02,01)),
      "March" => self.place_at_date(Date.new(2016,03,01)),
      "April" => self.place_at_date(Date.new(2016,04,01)),
      "May" => self.place_at_date(Date.new(2016,05,01)),
      "June" => self.place
    }
  end

  def monthly_point_progression
    hash = {
      "September" => self.points_at_date(Date.new(2015, "09".to_i, 01)),
      "October" => self.points_at_date(Date.new(2015,10,01)),
      "November" => self.points_at_date(Date.new(2015,11,01)),
      "December" => self.points_at_date(Date.new(2015,12,01)),
      "January" => self.points_at_date(Date.new(2016,01,01)),
      "February" => self.points_at_date(Date.new(2016,02,01)),
      "March" => self.points_at_date(Date.new(2016,03,01)),
      "April" => self.points_at_date(Date.new(2016,04,01)),
      "May" => self.points_at_date(Date.new(2016,05,01)),
      "June" => self.points_from_record(self.record)
    }
  end

  def winning_at_halftime
    self.games.select{|g| g.halftime_leader == self.name}
  end

  def losing_at_halftime
    self.games.select{|g| g.halftime_leader != self.name && g.half_time_result != "D"}
  end

  def tied_at_halftime
    self.games.select{|g| g.half_time_result == "D"}
  end

  def winning_at_halftime_record
    {"wins" => self.games_won.select{|g| self.winning_at_halftime.include?(g)}.count,
     "draws" => self.games_drawn.select{|g| self.winning_at_halftime.include?(g)}.count,
     "losses" =>self.games_lost.select{|g| self.winning_at_halftime.include?(g)}.count
  }
  end

  def losing_at_halftime_record
    {"wins" => self.games_won.select{|g| self.losing_at_halftime.include?(g)}.count,
     "draws" => self.games_drawn.select{|g| self.losing_at_halftime.include?(g)}.count,
     "losses" =>self.games_lost.select{|g| self.losing_at_halftime.include?(g)}.count
  }
  end

  def tied_at_halftime_record
    {"wins" => self.games_won.select{|g| self.tied_at_halftime.include?(g)}.count,
     "draws" => self.games_drawn.select{|g| self.tied_at_halftime.include?(g)}.count,
     "losses" =>self.games_lost.select{|g| self.tied_at_halftime.include?(g)}.count
  }
  end



  def self.losing_at_halftime_wins
    hash ={}
    self.all.each do |team|
      hash[team.name] = team.losing_at_halftime_record["wins"]
    end
    self.table_sorter(hash)
  end

  def self.losing_at_halftime_table
    hash ={}
    self.all.each do |team|
      hash[team.name] = team.points_from_record(team.losing_at_halftime_record)
    end
    arr = hash.sort_by{|k, v| v}.reverse
    hash = {}
    arr.each do |team|
      hash[team[0]] = team[1]
    end
    hash
  end

  def self.points_dropped_after_halftime_lead_table
    hash = {}
    self.all.each do |team|
      hash[team.name] = team.points_dropped_from_record(team.winning_at_halftime_record)   
    end
    self.table_sorter(hash)
  end

  def shutouts
    self.games.select{|g| !self.games_lost.include?(g) && g.shutout}
  end

  def self.shutout_table
    hash = {}
    self.all.each do |team|
      hash[team.name] = team.shutouts.count
    end
    self.table_sorter(hash)
  end

  def shots
    arr = self.games.map{|g| g.shot_count[self.name]}
    arr.inject(0, :+)
  end

  def shots_on_target
    arr = self.games.map{|g| g.sot_count[self.name]}
    arr.inject(0, :+)
  end

  def self.shot_conversion_table
    hash = {}
    self.all.each do |team|
      count = team.goals_scored.to_f/team.shots.to_f
      hash[team.name] = count.round(4)
    end
    self.table_sorter(hash)
  end

  def self.sot_conversion_table
    hash = {}
    self.all.each do |team|
      count = team.goals_scored.to_f/team.shots_on_target.to_f
      hash[team.name] = count.round(4)
    end
    self.table_sorter(hash)
  end

  def self.sot_to_shots_table
    hash = {}
    self.all.each do |team|
      count = team.shots_on_target.to_f/team.shots.to_f
      hash[team.name] = count.round(4)
    end
    self.table_sorter(hash)
  end

  def self.more_shots_and_lost_count
    hash ={}
    self.all.each do |team|
      hash[team.name] = team.games_lost.select{|g| g.more_shots_and_lost}.count
    end
    self.table_sorter(hash)
  end

  def self.fewer_shots_and_won_count
    hash = {}
    self.all.each do |team|
      hash[team.name] = team.games_won.select{|g| g.more_shots_and_lost}.count
    end
    self.table_sorter(hash)
  end

  def games_with_red_cards
    self.games.select{|g| g.red_cards[self.name] > 0}
  end

  def red_card_record
    {"wins" => self.games_won.select{|g| games_with_red_cards.include?(g)}.count,
    "draws" => self.games_drawn.select{|g| games_with_red_cards.include?(g)}.count,
    "losses" => self.games_lost.select{|g| games_with_red_cards.include?(g)}.count
  }
  end

  def self.red_card_points_table
    hash = {}
    self.all.each do |team|
      hash[team.name] = team.points_from_record(team.red_card_record)
    end
    self.table_sorter(hash)
  end

  def first_half_goals
    arr = self.games.map{|g| g.halftime_score[self.name]}
    arr.inject(0, :+)
  end

  def second_half_goals
    arr = self.games.map{|g| g.second_half_score[self.name]}
    arr.inject(0, :+)
  end

  def self.more_first_half_goals
    self.all.select{|t| t.first_half_goals > t.second_half_goals}
  end

  def self.more_second_half_goals
    self.all.select{|t| t.second_half_goals > t.first_half_goals}
  end

  def sot_percentage_per_game
    arr = self.games.map{|g| g.sot_percentage_per_team[self.name]}
    hash = {}
    counter = 0
    while counter < self.games.length
      string = "Game #{counter + 1}"
      hash[string] = arr[counter]
      counter += 1
    end
    hash
  end

  def most_sots_without_a_goal
    arr = self.games.select{|g| g.score[self.name] == 0}
    shots = arr.map{|g| g.sot_count[self.name]}
    shots.sort.last
  end

  def self.most_sots_without_a_goal
    hash = {}
    self.all.each do | team|
      hash[team.name] = team.most_sots_without_a_goal
    end
    self.table_sorter(hash)
  end

  def refs
    arr = self.games.map{|g| g.referee}
    arr.uniq
  end

  def record_with_ref(ref)
    {"wins" => self.games_won.select{|g| g.referee == ref}.count, 
    "draws" => self.games_drawn.select{|g| g.referee == ref}.count,
    "losses" => self.games_lost.select{|g| g.referee == ref}.count
  }
  end

  def points_per_ref
    hash = {}
    self.refs.each do |ref|
      hash[ref] = self.points_from_record(record_with_ref(ref))
    end
    self.class.table_sorter(hash)
  end

  def games_against(team)
    self.games.select{|g| g.teams.include?(team.name)}
  end

  def record_against(string)
    {"wins" => self.games_won.select{|g| self.games_against(team).include?(g)}.count, 
      "draws" =>self.games_drawn.select{|g| self.games_against(team).include?(g)}.count,
      "losses" => self.games_lost.select{|g| self.games_against(team).include?(g)}.count
    }
  end

  def season_sweep
    self.class.all.select{|t| self.points_from_record(self.record_against(t))==6}
  end

  def lost_both
    self.class.all.select{|t| self.points_from_record(self.record_against(t))==0}
  end

  def even_split
    self.class.all.select{|t| self.points_from_record(self.record_against(t))==2 || self.record_against(t))==4}
  end




end