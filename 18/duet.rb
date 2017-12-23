class CPU
  attr_accessor :other_cpu
  attr_reader :freq, :registers

  def initialize(instructions:)
    @queue = []
    @instructions = instructions
    @program_counter = 0
    @rcv = false

    register_names = instructions.map do |instruction|
      _, reg, _ = instruction.split(/\s/)
      reg
    end
    @registers = init_registers(register_names)
  end

  def init_registers(register_names)
    names = register_names.uniq.reject do |reg|
      reg.match? /\d+/
    end
    names.map do |register_name|
      [register_name, 0]
    end.to_h
  end

  def run_program
    loop do
      execute
      break if @rcv
    end
  end

  # a source is either a inter value or a register
  def value_of(source:)
    return if source.nil?
    case source
    when /\d+/
      source.to_i
    else
      @registers[source]
    end
  end

  def execute
    instruction = @instructions[@program_counter]

    cmd, op1, op2 = instruction.split(/\s/)

    case cmd
    when "snd"
      @freq = value_of(source: op1)

    when "set"
      @registers[op1] = value_of(source: op2)

    when "add"
      @registers[op1] += value_of(source: op2)

    when "mul"
      @registers[op1] *= value_of(source: op2)

    when "mod"
      mod = value_of(source: op2)
      @registers[op1] = @registers[op1] % mod

    when "rcv"
      @rcv = true if @registers[op1] > 0

    when "jgz"
      if value_of(source: op1) > 0
        @program_counter += value_of(source: op2) - 1
      end

    end
    @program_counter = @program_counter + 1
  end
end

instructions = File.read("instructions_part1.txt")
instructions = instructions.split(/\n/).reject(&:empty?)

cpu = CPU.new(instructions: instructions)
cpu.run_program
puts "recovered freq: #{cpu.freq}"
