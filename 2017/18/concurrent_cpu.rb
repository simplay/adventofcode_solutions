class CPU
  attr_accessor :other_cpu
  attr_reader :send_count,
              :registers,
              :wait_for_buffer,
              :state,
              :program_counter

  def initialize(id: 0, instructions:)
    @id = id
    @queue = []
    @instructions = instructions
    @program_counter = 0
    @send_count = 0
    @state = :running

    register_names = instructions.map do |instruction|
      _, reg, _ = instruction.split(/\s/)
      reg
    end

    @registers = init_registers(register_names)
    update_p_register
  end

  def pc_out_of_bound?
    @program_counter < 0 || @program_counter >= @instructions.count
  end

  def update_p_register
    @registers["p"] = @id
  end

  def init_registers(register_names)
    names = register_names.uniq.reject do |reg|
      reg.match? /\d+/
    end
    names.map do |register_name|
      [register_name, 0]
    end.to_h
  end

  def add_to_queue(value)
    @queue << value
  end

  def take_from_queue
    @queue.shift
  end

  def run_program
    until pc_out_of_bound?
      is_done = do_step
      break if is_done
    end
  end

  # this is an assumption
  def same_pc?
    @program_counter == other_cpu.program_counter
  end

  # @return [Boolean] true if is done otherwise false
  def do_step
    instruction = @instructions[@program_counter]
    puts "cpu#{@id}@#{@state}: #{instruction}"

    if @wait_for_buffer
      @state = %i(waiting still_waiting).include?(state) ? :still_waiting : :waiting
      unless @queue.empty?
        val = take_from_queue
        @registers[@buffer_reg] = val
        @wait_for_buffer = false
        @buffer_reg = nil
        @state = :running
      end
    else
      execute
    end

    return true if both_still_waiting? && same_pc?
    false
  end

  def still_waiting?
    state == :still_waiting
  end

  def both_still_waiting?
    still_waiting? && other_cpu.still_waiting?
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
    @jump_done = false
    instruction = @instructions[@program_counter]

    cmd, op1, op2 = instruction.split(/\s/)

    case cmd
    when "snd"
      @send_count += 1
      other_cpu.add_to_queue(value_of(source: op1))

    when "set"
      @registers[op1] = value_of(source: op2)

    when "add"
      @registers[op1] += value_of(source: op2)

    when "mul"
      @registers[op1] *= value_of(source: op2)

    when "mod"
      @registers[op1] = @registers[op1] % value_of(source: op2)

    when "rcv"
      @buffer_reg = op1
      queue_is_empty = @queue.empty?
      @wait_for_buffer = queue_is_empty
      @registers[@buffer_reg] = take_from_queue unless queue_is_empty

    when "jgz"
      if value_of(source: op1) > 0
        @program_counter += value_of(source: op2) - 1
      end
    end

    @program_counter = @program_counter + 1
  end
end

instructions = File.read("instructions_part2.txt")
instructions = instructions.split(/\n/).reject(&:empty?)

cpu1 = CPU.new(id: 0, instructions: instructions)
cpu2 = CPU.new(id: 1, instructions: instructions)

cpu1.other_cpu = cpu2
cpu2.other_cpu = cpu1

threads = []
threads << Thread.new do
  sleep 1
  cpu1.run_program
end

threads << Thread.new do
  sleep 1
  cpu2.run_program
end

threads.each do |t|
  t.join
end

puts ""
puts "send count cpu 1: #{cpu1.send_count}"
puts "send count cpu 2: #{cpu2.send_count}"
