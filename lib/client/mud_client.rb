require 'socket'
require 'thread'

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

class MudReader < Looper
  def initialize(socket, bot)
    super("Reader")
    @socket = socket
    @bot = bot
  end

  def do_action
    puts "Reader> reading"
    string = @socket.recv(4*1024)
    puts "Reader> read #{string}"
    stop if string.nil? || string.empty?
    print(string) if !string.nil? && !string.empty?
  end
end

class UserInput < Looper
  def initialize(bot)
    super("UserInput")
    @bot = bot
  end

  def do_action
    line = gets
    puts "UserInput>read #{line}"
    @bot.issue_command(line)
  end
end

class DoNothingStrategy
  def next_command
    nil
  end
end

class Bot < Looper
  def initialize(socket)
    super("Bot", 1) #commands are issued once per second
    @mutex = Mutex.new
    @strategy = DoNothingStrategy.new
    @mutex.synchronize do
      @socket = socket
    end
  end

  def do_action
    command = @strategy.next_command
    issue_command(command) unless command.nil?
  end

  def issue_command(command)
    puts "Bot> issuing command #{command}"
    if command.start_with? "bot:"
      print "Bot> Caught bot command #{command}, doing nothing."
      #TODO parse command
    else
      @mutex.synchronize do
        puts "Bot> sending command #{command}"
        @socket.send command + "\n", 0
      end
    end
  end
end

socket = TCPSocket.new("falloutmud.org", 2222)
bot = Bot.new(socket)

bot_thread = Thread.new do
  bot.loop
end

reader_thread = Thread.new(socket, bot) do |s, b|
  MudReader.new(s, b).loop
end

input_thread = Thread.new(bot) do |b|
  UserInput.new(b).loop
end

bot_thread.join
reader_thread.join
input_thread.join



