require 'yaml'

require './lib/client/looper'
require './lib/client/item_registry'
require './lib/client/strategy'

class Bot < Looper
  attr_reader :position, :prev_position
  attr_writer :strategy

  def initialize(socket, position)
    super("Bot", 1) #commands are issued once per second
    @mutex = Mutex.new
    @log = open('lore.log', 'a')

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
      case command
      when "bot:collect" then @strategy = CollectStrategy.new(self)
      when "bot:shopping" then @strategy = GotoShopStrategy.new(@position)
      when "bot:sell" then @strategy = SellAllStrategy.new
      when "bot:position" then puts "Bot position=#{@position} prev_position=#{@prev_position}"
      else puts "Dont know this command: #{command}"
      end
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
    @log << "----------- #{Time.now}\n"
    @log << string
    changes = {}
    if string =~ /What do they call ya/
      changes[:login_requested] = true
    elsif string =~ /Access co/
      changes[:password_requested] = true
    elsif string =~ /Welcome to/
      changes[:menu_appeared] = true
    elsif string =~ /PRESS RETURN/
      changes[:menu_press_enter] = true
    elsif string =~ /A security guard stands here/
      @position = Position.new(6,2)
      @strategy = CollectStrategy.new(self)
    elsif string =~ /(arms are already full|hands are full)/
      @strategy = GotoShopStrategy.new(@position)
    elsif string =~ /You can't go that way, asswipe/
      move_rollback
    elsif string =~ /You are carrying:/
      changes[:inventory] = parse_inventory(string)
      puts "Parsed inventory: #{changes[:inventory]}"
      if changes[:inventory].empty?
        @strategy = CollectStrategy.new(self)
      end
    elsif string =~ /There doesn't seem to be anything here/
      changes[:empty] = true
    elsif string =~ /buck or two from selling your crap/
      @position = Position.new(1,3)
      @strategy = SellAllStrategy.new
    end

    unless changes.empty?
      puts "Changes: #{changes}"
      @model.merge!(changes)
      @strategy.update(changes)
    end
  end

  def parse_inventory(inv_string)
    #puts "\n---parse_inv---\n#{inv_string}\n---------"
    #string = inv_string.match(/You are carrying:(\n\(\s*[0-9]+\)\s+[\sa-zA-Z0-9]+)+/)[1]
    inventory = {}
    inv_string.strip.split("\n").drop(1).each do |line|
      puts "processing line: #{line}"
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
    puts "Inventory is #{inventory}"
    inventory
  end
end
