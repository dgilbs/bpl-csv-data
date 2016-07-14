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

  def self.find(name)
    self.all.find{|r| r.name == name}
  end

end