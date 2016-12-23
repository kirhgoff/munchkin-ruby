class LoreModel
  attr_accessor :need_login, :need_password

  @need_login = false
  @need_password = false
end

class Bot < Looper
  def initialize(socket)
    super("Bot", 1) #commands are issued once per second
    @mutex = Mutex.new

    @model = LoreModel.new
    @strategy = LoginStrategy.new
    # is it needed?
    @mutex.synchronize do
      @socket = socket
    end
  end

  def do_action
    command = @strategy.next_command unless @strategy.nil?
    issue_command(command) unless command.nil?
  end

  def issue_command(command)
    if command.start_with? "bot:"
      print "Bot> Caught bot command #{command}, doing nothing."
      @strategy = GotoShopStrategy.new if command == "bot:shopping"
    else
      @mutex.synchronize do
        @socket.send command + "\n", 0
      end
    end
  end

  def parse_lore(string)
    @model.need_login = string =~ /What do they call ya/
    @model.need_password = string =~ /Access Code/

    @strategy.update(@model)
  end
end

class LoginStrategy
  def next_command
    nil
  end
end


class DoNothingStrategy
  def next_command
    nil
  end
end

class GotoShopStrategy
  def initialize
    puts "Created goto shop strategy"
    @maze = Maze.new(MAP)
    @path = @maze.find_path(position(6, 2), position(1, 3)).reverse
    puts "path is: #{@path}"
  end

  def next_command
    puts "Remaining path: #{@path.inspect}"
    nil if @path.empty?
    @path.pop.to_s
  end
end

