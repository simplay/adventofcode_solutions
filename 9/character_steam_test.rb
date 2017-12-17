require 'minitest/autorun'
require 'minitest/pride'

class CharacterStream
  attr_reader :sequence

  def initialize(sequence)
    @sequence = sequence
    cleanup_bangs
    cleanup_garbage
  end

  def group_count
    sequence.scan(/{/).count
  end
  
  def score
    visit(0)
  end

  private

  def visit(sum, index = 0, nesting_level = 1)
    new_nesting_level = nesting_level
    case sequence[index]
    when "{"
      sum += nesting_level
      new_nesting_level += 1
    when "}"
      new_nesting_level -= 1
    end
    
    if index < sequence.length
      visit(sum, index + 1, new_nesting_level)
    else
      sum
    end
  end

  def cleanup_bangs
    sequence.gsub!(/!./, '')
  end

  # make match non-greedy by adding a ?
  def cleanup_garbage
    sequence.gsub!(/<.*?>/, '')
  end
end

class CharacterStreamTest < MiniTest::Test
  def test_bang
    assert_equal("{}", CharacterStream.new("{!a}").sequence)
  end

  def test_removes_garbage
    assert_equal("", CharacterStream.new("<<<<>").sequence)
    assert_equal("", CharacterStream.new("<random characters>").sequence)
    assert_equal("", CharacterStream.new("<>").sequence)
    assert_equal("", CharacterStream.new("<{!>}>").sequence)
    assert_equal("", CharacterStream.new("<!!>").sequence)
    assert_equal("", CharacterStream.new("<!!!>>").sequence)
    assert_equal("", CharacterStream.new("<{o\"i!a,<{i<a>").sequence)
  end

  def test_cleanup
    assert_equal("{}", CharacterStream.new("{}").sequence)
    assert_equal("{{{}}}", CharacterStream.new("{{{}}}").sequence)
    assert_equal("{{{},{},{{}}}}", CharacterStream.new("{{{},{},{{}}}}").sequence)
    assert_equal("{}", CharacterStream.new("{<{},{},{{}}>}").sequence)
    assert_equal("{{},{},{},{}}", CharacterStream.new("{{<a>},{<a>},{<a>},{<a>}}").sequence)
    assert_equal("{,,,}", CharacterStream.new("{<a>,<a>,<a>,<a>}").sequence)
    assert_equal("{{}}", CharacterStream.new("{{<!>},{<!>},{<!>},{<a>}}").sequence)
  end

  def test_group_count
    assert_equal(1, CharacterStream.new("{}").group_count)
    assert_equal(3, CharacterStream.new("{{{}}}").group_count)
    assert_equal(6, CharacterStream.new("{{{},{},{{}}}}").group_count)
    assert_equal(1, CharacterStream.new("{<{},{},{{}}>}").group_count)
    assert_equal(5, CharacterStream.new("{{<a>},{<a>},{<a>},{<a>}}").group_count)
    assert_equal(1, CharacterStream.new("{<a>,<a>,<a>,<a>}").group_count)
    assert_equal(2, CharacterStream.new("{{<!>},{<!>},{<!>},{<a>}}").group_count)
  end

  def test_count
    assert_equal(1, CharacterStream.new("{}").score)
    assert_equal(6, CharacterStream.new("{{{}}}").score)
    assert_equal(16, CharacterStream.new("{{{},{},{{}}}}").score)
    assert_equal(1, CharacterStream.new("{<a>,<a>,<a>,<a>}").group_count)
    assert_equal(9, CharacterStream.new("{{<ab>},{<ab>},{<ab>},{<ab>}}").score)
    assert_equal(9, CharacterStream.new("{{<!!>},{<!!>},{<!!>},{<!!>}}").score)
    assert_equal(3, CharacterStream.new("{{<a!>},{<a!>},{<a!>},{<ab>}}").score)
  end

  def test_final_result
    sequence = File.read("data.txt").chomp
    score = CharacterStream.new(sequence).score
    assert_equal(11089, score)
  end
end

sequence = File.read("data.txt").chomp
score = CharacterStream.new(sequence).score
puts "score: #{score}"
