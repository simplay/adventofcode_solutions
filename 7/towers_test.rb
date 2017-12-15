require 'minitest/autorun'
require 'minitest/pride'

class Program
  attr_accessor :parent, :weight, :balance_sum
  attr_reader :name, :children

  def initialize(name)
    @name = name
    @children = []
    @is_balanced = false
    @balance_sum = 0
  end

  def root?
    parent.nil?
  end

  def leaf?
    children.empty?
  end

  def balanced?
    return true if leaf?
    @is_balanced
  end

  def balanced!
    @is_balanced = true
  end

  def add(child)
    children << child
  end
end

class Towers
  attr_reader :programs,
              :issue_children

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
      program.weight = weight.gsub(/\(|\)/, '').to_i

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

  def balanced?
    @once = true
    compute_balance_sums(root)
    check_balance(root)
    root.balanced?
  end

  def compute_balance_sums(node)
    node.children.each do |child_node|
      compute_balance_sums(child_node)
      node.balance_sum += child_node.balance_sum
    end
    node.balance_sum += node.weight
  end

  def check_balance(node)
    is_balanced = true
    node.children.each do |child_node|
      check_balance(child_node)
      is_balanced = node.children.map(&:balance_sum).uniq.count == 1
    end
    if is_balanced
      node.balanced!
    else

      # fetch only most bottom issue children
      # to correct the tree from below (i.e. propagate
      # corrections to the root)
      if @once
        @once = false
        @issue_children = node.children
      end
    end
  end

  def fixed_weight_of_issue_program
    issue_groups = issue_children.group_by do |node|
      node.balance_sum
    end

    issue_program = issue_groups.find do |weight, group|
      group.count == 1
    end.last.first

    okay_program = issue_groups.find do |_, group|
      group.count > 1
    end.last.last

    delta_weight = issue_program.balance_sum - okay_program.balance_sum

    issue_program.weight - delta_weight
  end
end

class TowersTest < MiniTest::Test
  def test_program1
    towers = Towers.new("test_data.txt")
    assert_equal("tknk", towers.root.name)
  end

  def test_issue_program
    towers = Towers.new("test_data.txt")
    refute towers.balanced?
    fixed_weight = towers.fixed_weight_of_issue_program
    assert_equal(60, fixed_weight)
  end
end

# part 1
towers = Towers.new("real_data.txt")
root_name = towers.root.name
puts "root name: #{root_name}"

# part 2
towers.balanced?
fixed_weight = towers.fixed_weight_of_issue_program
puts "fixed weight: #{fixed_weight}"
