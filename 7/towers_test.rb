require 'minitest/autorun'
require 'minitest/pride'

class Program
  attr_accessor :parent
  attr_reader :name, :children

  def initialize(name)
    @name = name
    @children = []
  end

  def root?
    parent.nil?
  end

  def leaf?
    children.empty?
  end

  def add(child)
    children << child
  end
end

class Towers
  attr_reader :programs

  def initialize(filename)
    @programs = {}

    program_data = File.read(filename).split("\n")

    program_data.each do |data|
      name = data.split(" ").first
      program = Program.new(name)
      @programs[name] = program
    end

    program_data.each do |data|
      name, weight, _, *child_program_names = data.split(" ")
      child_program_names.map! { |program_name| program_name.gsub(',', '')}
      program = @programs[name]

      child_program_names.each do |program_name|
        child_program = @programs[program_name]
        if child_program
          program.add(child_program) if child_program
          child_program.parent = program
        end
      end
    end
  end

  def root
    programs.values.find do |program| 
      program.parent.nil? 
    end
  end
end

class TowersTest < MiniTest::Test
  def test_program1
    towers = Towers.new("test_data.txt")
    assert_equal("tknk", towers.root.name)
  end
end

towers = Towers.new("real_data.txt")
root_name = towers.root.name
puts "root name: #{root_name}"
