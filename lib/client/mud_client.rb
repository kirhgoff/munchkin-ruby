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



