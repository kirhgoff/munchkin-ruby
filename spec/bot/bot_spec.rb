require './lib/client/bot'
require './lib/maze/position'

RSpec.describe Bot do

  it "can detect movement commands" do
    socket = double('Socket')
    bot = Bot.new(socket, position(1, 1))

    # Going west
    expect(socket).to receive(:send).with("w\n", 0)
    bot.issue_command('w')
    expect(bot.position).to eq position(0,1)

    #Incorrect movement
    bot.parse_lore("You can't go that way, asswipe")
    expect(bot.position).to eq position(1,1)
  end

end