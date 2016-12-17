require 'socket'

class MudReader
  def read_lore(socket)
    puts "Reader> Started"
    while true
      string = socket.recv(4*1024)
      break if string.nil? || string.empty?
      print(string)
      sleep 0.5
    end
    puts "Reader> Finished"
  end
end

class MudWriter
  def read_user_input(socket)
    puts "Writer> Started"
    while true
      line = gets
      socket.send line + "\n", 0
    end
    puts "Writer> Finished"
  end
end

socket = TCPSocket.new("falloutmud.org", 2222)
reader = Thread.new {MudReader.new.read_lore(socket)}
writer = Thread.new {MudWriter.new.read_user_input(socket)}

reader.join
writer.join



