require 'minitest/autorun'
require 'minitest/pride'

class CharacterStream
  attr_reader :sequence

  def initialize(sequence)
    @sequence = sequence
    cleanup_bangs
    @raw_without_bangs = String.new(sequence)
    cleanup_garbage
  end

  def group_count
    sequence.scan(/{/).count
  end
  
  def score
    compute_score(0)
  end

  def garbage_count
    trash = []
    t = compute_garbage_count(0, trash, [], false)
    t.flatten.count
  end

  private

  def compute_garbage_count(i = 0, trash, current_garbage, started)
    index = i
    loop do
      case @raw_without_bangs[index]
      when '<'
        # start new block
        if started
          current_garbage << @raw_without_bangs[index]
        else
          started = true
          current_garbage = []
        end
      when '>'
        started = false
        trash << current_garbage 
        # remember
      else
        if started
          current_garbage << @raw_without_bangs[index]
        end
      end

      if index < @raw_without_bangs.length
        index += 1
      else
        return trash
      end
    end
  end

  def compute_score(sum, index = 0, nesting_level = 1)
    new_nesting_level = nesting_level
    case sequence[index]
    when "{"
      sum += nesting_level
      new_nesting_level += 1
    when "}"
      new_nesting_level -= 1
    end
    
    if index < sequence.length
      compute_score(sum, index + 1, new_nesting_level)
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

  def test_gc
    assert_equal(0, CharacterStream.new("<>").garbage_count)
    assert_equal(17, CharacterStream.new("<random characters>").garbage_count)
    assert_equal(3, CharacterStream.new("<<<<>").garbage_count)
    assert_equal(2, CharacterStream.new("<{!>}>").garbage_count)
    assert_equal(0, CharacterStream.new("<!!>").garbage_count)
    assert_equal(0, CharacterStream.new("<!!!>>").garbage_count)
    assert_equal(10, CharacterStream.new("<{o\"i!a,<i<a}>").garbage_count)

    sequence = File.read("data.txt").chomp
    gc = CharacterStream.new(sequence).garbage_count
    assert_equal(5288, gc)
  end
end

# part 1
sequence = File.read("data.txt").chomp
score = CharacterStream.new(sequence).score
puts "score: #{score}"

# part 2
sequence = File.read("data.txt").chomp
gc = CharacterStream.new(sequence).garbage_count
puts "garbage count: #{gc}"
