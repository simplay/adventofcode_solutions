require_relative '../18/cpu.rb'
require 'prime'

# c = 125_100
# b = 108_100
# h = 0
#
# # checks whether the current b is a prime number
# # while b != c
# 1000.times do |idx|
#   # flag f indicates whether current b is a prime
#   # f == 1 => b is prime
#   f = 1
#   d = 2
#   while d != b
#     e = 2
#     while e != b
#       # b has divisors d and e => not a prime
#       f = 0 if d * e  == b
#       break if f == 0
#       e += 1
#     end
#     d += 1
#     break if f == 0
#   end
#
#   h += 1 if f == 0
#   b += 17
#   puts "Iter #{idx + 1}"
# end
class CoProcessor < CPU

  def pc_out_of_bound?
    @program_counter < 0 || @program_counter >= @instructions.count
  end

  def run_program
    until pc_out_of_bound?
      if @optimized && @program_counter == 9
        b_is_prime = Prime.prime?(@registers['b'])
        @registers['f'] =  b_is_prime ? 1 : 0

        # goto 23
        @program_counter += 15
        next
      end

      execute
    end
  end

  def post_steps
    @registers["a"] = 1 if @optimized
  end
end

instructions = File.read('instructions')
instructions = instructions.split(/\n/).reject(&:empty?)

cpu = CoProcessor.new(instructions: instructions)
cpu.run_program
puts cpu.mul_counter

cpu = CoProcessor.new(instructions: instructions, optimized: true)
cpu.run_program
puts "register h: #{cpu.registers["h"]}"
