require 'socket'
require 'thread'

require './lib/client/looper'
require './lib/client/bot'
require './lib/maze/map'

class MudReader < Looper
  def initialize(socket, bot)
    super("Reader")
    @socket = socket
    @bot = bot
  end

  def do_action
    string = @socket.recv(4*1024)
    #puts "Reader> read #{string}"
    stop if string.nil? || string.empty?
    print(string) if !string.nil? && !string.empty?
    @bot.parse_lore(string)
  end
end

class UserInput < Looper
  def initialize(bot)
    super("UserInput")
    @bot = bot
  end

  def do_action
    line = gets
    #puts "UserInput>read #{line}"
    @bot.issue_command(line.chomp)
  end
end

def exception(e,name)
  puts "EXCEPTION:#{name} #{e.inspect}"
  puts "MESSAGE:#{name} #{e.message}"
  puts e.backtrace.join("\n\t").sub("\n\t", ": #{e}#{e.class ? " (#{e.class})" : ''}\n\t")
end

socket = TCPSocket.new("falloutmud.org", 2222)
bot = Bot.new(socket, position(6, 2))

bot_thread = Thread.new do
  begin
    bot.loop
  rescue Exception => e
    exception(e,"Bot")
  end
end

reader_thread = Thread.new(socket, bot) do |s, b|
  begin
    MudReader.new(s, b).loop
  rescue Exception => e
    exception(e,"Reader")
  end
end

input_thread = Thread.new(bot) do |b|
  begin
    UserInput.new(b).loop
  rescue Exception => e
    exception(e, "UserInput")
  end
end

bot_thread.join
reader_thread.join
input_thread.join



