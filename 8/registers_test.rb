require 'minitest/autorun'
require 'minitest/pride'

class RegistersTest < MiniTest::Test
  def test_foo

  end
end

class Register
  attr_reader :name, :value

  def initialize(name)
    @name = name
    @value = 0
  end

  def inc(value)
    @value += value.to_i
  end

  def dec(value)
    @value -= value.to_i
  end
end

registers = {}
global_max_value = -100_000_000_000

filename = "real_data.txt"
instructions = File.read(filename).split("\n")

instructions.each do |instruction|
  register_name, *rest = instruction.split(" ")
  registers[register_name] = Register.new(register_name)
end

instructions.each do |instruction|
  register_name, op, value, *cond = instruction.split(" ")
  register = registers[register_name]

  left, cmp_op, cmp_value = cond[1..-1]
  condition = eval("#{registers[left].value} #{cmp_op} #{cmp_value.to_i}")
  register.send(op, value) if condition

  m = registers.values.map(&:value).max
  if m >= global_max_value
    global_max_value = m
  end
end

max_value = -100_000_000_000
max_reg = nil
registers.values.each do |reg|
  if reg.value >= max_value
    max_reg = reg
    max_value = reg.value
  end
end
puts "max reg: #{max_reg.name} with #{max_reg.value}"
puts "global max reg: #{global_max_value}"
