require 'yaml'

require './lib/client/looper'

class Bot < Looper
  attr_reader :position

  def initialize(socket)
    super("Bot", 1) #commands are issued once per second
    @mutex = Mutex.new
    @position = Position.new(6, 2)

    @model = {}
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
      @strategy = GotoShopStrategy.new(@position) if command == "bot:shopping"
    else
      @mutex.synchronize do
        @socket.send command + "\n", 0
      end
    end
  end

  def parse_lore(string)
    changes = {}
    if string =~ /What do they call ya/
      changes[:login_requested] = true
    elsif string =~ /Access /
      changes[:password_requested] = true
    elsif string =~ /Welcome to/
      changes[:menu_appeared] = true
    elsif string =~ /PRESS RETURN/
      changes[:menu_press_enter] = true
    end

    unless changes.empty?
      puts "Changes: #{changes}"
      @model.merge!(changes)
      @strategy.update(changes, @model)
    end
  end
end

class ModelListener
  def update(changes, model)
  end
end

class LoginStrategy < ModelListener
  @command = nil
  def initialize
    @credentials = YAML.load_file("#{ENV['HOME']}/.munchkin")
    puts "Credentials: #{@credentials}"
  end

  def next_command
    result = @command
    @command = nil
    puts "\nLogin command=#{result}" unless result.nil?
    result
  end

  def update(changes, _)
    if changes.key?(:password_requested)
      @command = @credentials[:password]
    elsif changes.key?(:login_requested)
      @command = @credentials[:login]
    elsif changes.key?(:menu_press_enter)
      @command = ""
    elsif changes.key?(:menu_appeared)
      @command = "1"
    else
      @command = nil
    end
  end

end


class DoNothingStrategy  < ModelListener
  def next_command
    nil
  end
end

class GotoShopStrategy < ModelListener
  def initialize(position)
    puts "Created goto shop strategy"
    @maze = Maze.new(MAP)
    @path = @maze.find_path(position(6, 2), position).reverse
    puts "path is: #{@path}"
  end

  def next_command
    puts "Remaining path: #{@path.inspect}"
    nil if @path.empty?
    @path.pop.to_s
  end
end

