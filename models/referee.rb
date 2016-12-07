require 'pry'
require 'json'


class Referee
  attr_accessor :name

  @@all = []

  def initialize(name)
    @name = name
    @@all << self
  end

  def games
    Game.all.select{|g| g.referee == self.name}
  end

  def self.all 
    @@all 
  end

  def self.all_names
    self.all.map{|r| r.name}.uniq
  end

  def self.table_sorter(hash)
    arr = hash.sort_by{|k, v| v}.reverse
    hash = {}
    arr.each do |ref|
      hash[ref[0]] = ref[1]
    end
    hash
  end

  def self.find(name)
    self.all.find{|r| r.name == name}
  end

  def teams
    self.games.map{|g| g.teams}.flatten.uniq
  end

  def fouls_called
    arr = self.games.map{|g| g.total_fouls}
    arr.inject(0, :+)
  end

  def game_count
    self.games.count
  end

  def self.fouls_per_game_table
    hash = {}
    self.all.each do |ref|
      hash[ref.name] = (ref.fouls_called.to_f/ref.game_count.to_f).round(2) if ref.game_count > 5
    end
    self.table_sorter(hash)
  end

  def games_with_team(team)
    self.games.select{|g| g.teams.include?(team)}
  end

  def game_count_with_team(team)
    self.games_with_team(team).count
  end

  def most_common_team
    
  end

  def fouls_called_on_team(team)
    count = 0
    arr = self.games.select{|g| g.teams.include?(team)}
    arr.each do |game|
      count += game.fouls[team]
    end
    count
  end

  def fpg_per_team
    hash = {}
    self.teams.each do |team|
      num = self.fouls_called_on_team(team).to_f/self.game_count_with_team(team).to_f
      hash[team] = num.round(2)
    end
    self.class.table_sorter(hash)
  end

  def table
    hash = {}
    self.teams.each do |team|
      t = Team.find(team)
      hash[team] = t.points_from_record(t.record_with_ref(self.name))
    end
    self.class.table_sorter(hash)
  end

end