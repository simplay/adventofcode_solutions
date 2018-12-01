require_relative 'cpu.rb'

instructions = File.read("instructions_part1.txt")
instructions = instructions.split(/\n/).reject(&:empty?)

cpu = CPU.new(instructions: instructions)
cpu.run_program
puts "recovered freq: #{cpu.freq}"
