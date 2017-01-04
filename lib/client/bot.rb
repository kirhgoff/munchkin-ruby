require 'yaml'

require './lib/client/looper'
require './lib/client/item_registry'

class Bot < Looper
  attr_reader :position, :prev_position
  attr_writer :strategy

  def initialize(socket, position)
    super("Bot", 1) #commands are issued once per second
    @mutex = Mutex.new

    @position = position
    @prev_position = position

    @model = {}
    @item_registry = ItemRegistry.new
    @strategy = LoginStrategy.new
    # is it needed?
    @mutex.synchronize do
      @socket = socket
    end
  end

  def do_action
    unless @strategy.nil?
      command = @strategy.next_command
      issue_command(command) unless command.nil?
    end
  end

  def move(direction)
    @prev_position = position
    @position = position.move(direction)
  end

  def move_rollback
    @position = @prev_position
  end

  def issue_command(command)
    if command.start_with? "bot:"
      print "Bot> Caught bot command #{command}, doing nothing."
      @strategy = GotoShopStrategy.new(@position) if command == "bot:shopping"
      puts "Bot position=#{@position} prev_position=#{@prev_position}" if command == "bot:position"
    else
      # We monitor our position
      direction = Direction.parse(command)
      move(direction) unless direction.nil?

      @mutex.synchronize do
        @socket.send command + "\n", 0
      end
    end
    @strategy = LogoutStrategy.new if command == "quitnow"
  end

  def parse_lore(string)
    changes = {}
    if string =~ /What do they call ya/
      changes[:login_requested] = true
    elsif string =~ /Access co/
      changes[:password_requested] = true
    elsif string =~ /Welcome to/
      changes[:menu_appeared] = true
    elsif string =~ /PRESS RETURN/
      changes[:menu_press_enter] = true
    elsif string =~ /(arms are already full|hands are full)/
      @strategy = GotoShopStrategy.new(@position)
    elsif string =~ /You can't go that way, asswipe/
      move_rollback
    elsif string =~ /You are carrying:\n((\(\s[0-9]+\))*\s*(a|an).*\n)*/
      changes[:inventory] = parse_inventory(string)
    end

    unless changes.empty?
      puts "Changes: #{changes}"
      @model.merge!(changes)
      @strategy.update(changes)
    end
  end

  def parse_inventory(string)
    inventory = {}
    string.split("\n").drop(1).each do |line|
      line = line.strip
      quantity = 1
      if line.start_with? "("
        closing_bracket = line.index(")")
        quantity = line.slice(1, closing_bracket - 1).strip.to_i
        line = line.slice(closing_bracket + 1, line.length - closing_bracket - 1).strip
      end
      symbol = @item_registry.parse(line)
      puts "Q=#{quantity} I=#{line} S=#{symbol}"
      inventory[symbol] = quantity
    end
    inventory
  end
end

class ModelListener
  def update(changes)
  end
end

class LogoutStrategy < ModelListener
  @command = nil
  def next_command
    @command
  end

  def update(changes)
    if changes.key?(:menu_appeared)
      @command = "0"
    end
  end
end

class LoginStrategy < ModelListener
  @command = nil
  def initialize
    @credentials = YAML.load_file("#{ENV['HOME']}/.munchkin")
  end

  def next_command
    result = @command
    @command = nil
    puts "\nLogin command=#{result}" unless result.nil?
    result
  end

  def update(changes)
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

class SellAllStrategy < ModelListener
  def update(changes)
  end
end

