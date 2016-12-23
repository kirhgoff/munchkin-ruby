class Looper
  def initialize(name, delay = 0.1)
    @stop_flag = false
    @name = name
    @delay = delay
  end

  def loop
    puts "#{@name}> Started"
    until @stop_flag
      #puts "#{@name}> Action..."
      do_action
      sleep @delay
    end
    puts "#{@name}> Finished"

  end

  def do_action
    # method to override
  end

  def stop
    @stop_flag = true
    puts "#{@name}> Stopping..."
  end
end
