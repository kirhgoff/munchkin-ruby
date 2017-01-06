class ModelListener
  def update(changes)
  end
end

#=============================================

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

#=============================================

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


#=============================================

class GotoShopStrategy < ModelListener
  def initialize(position)
    puts "Created goto shop strategy"
    @maze = Maze.new(MAP)
    puts "Position is: #{position}"
    @path = @maze.find_path(position, position(1,3)).reverse
    puts "path is: #{@path}"
  end

  def next_command
    unless @path.empty?
      @path.pop.to_s
    else
      nil
    end
  end
end

#=============================================

class SellAllStrategy < ModelListener
  def initialize
    puts "Created sellall strategy"
    @inventory = {}
  end

  def update(changes)
    @inventory = changes[:inventory]
    puts "Not inventory is #{@inventory}"
  end

  def next_command
    if @inventory.empty?
      "inv"
    else
      name,count = @inventory.pop
      puts "Selling #{name} count=#{count}"
      count != 1 ? "sell #{count} #{name}" : "sell #{name}"
    end
  end
end


#=============================================

class CollectStrategy < ModelListener
  def initialize(bot)
    @maze = Maze.new(MAP)
    @bot = bot
  end

  def next_command
    [true, false].sample ? "get all" : roam.to_s
  end

  def roam
    @maze.wander(@bot.position).sample
  end
end


