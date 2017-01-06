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
    @path = @maze.find_path(position(6, 2), position).reverse
    puts "path is: #{@path}"
  end

  def next_command
    puts "Remaining path: #{@path.inspect}"
    nil if @path.empty?
    @path.pop.to_s
  end
end

#=============================================

class SellAllStrategy < ModelListener
  def update(changes)
  end
end


#=============================================

class CollectStrategy < ModelListener
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


