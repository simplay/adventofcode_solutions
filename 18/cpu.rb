class CPU
  attr_accessor :other_cpu
  attr_reader :freq, :registers, :mul_counter

  def initialize(instructions:, optimized: false)
    @queue = []
    @instructions = instructions
    @program_counter = 0
    @mul_counter = 0
    @rcv = false
    @optimized = optimized

    register_names = instructions.map do |instruction|
      _, reg, _ = instruction.split(/\s/)
      reg
    end
    @registers = init_registers(register_names)
    post_steps
  end

  def post_steps; end

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

    when "sub"
      @registers[op1] -= value_of(source: op2)

    when "add"
      @registers[op1] += value_of(source: op2)

    when "mul"
      @mul_counter += 1
      @registers[op1] *= value_of(source: op2)

    when "mod"
      @registers[op1] = @registers[op1] % value_of(source: op2)

    when "rcv"
      @rcv = true if @registers[op1] > 0

    when "jgz"
      if value_of(source: op1) > 0
        @program_counter += value_of(source: op2) - 1
      end
    when "jnz"
      if value_of(source: op1) != 0
        @program_counter += value_of(source: op2) - 1
      end
    end
    @program_counter = @program_counter + 1
  end
end
