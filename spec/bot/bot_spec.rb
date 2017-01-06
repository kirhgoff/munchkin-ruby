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

  it "can parse inventory" do
    strategy = double('Strategy')

    bot = Bot.new(nil, nil)
    bot.strategy = strategy

    # Going west
    expect(strategy).to receive(:update).with(
        {:inventory =>
             {:soda => 3, :newspaper => 1, :flip => 1, :shard => 15}
        })

    bot.parse_lore(
      "asdasdasdasdas\n"+
      "You are carrying:\n" +
      "(15) a shard of broken glass\n" +
      "( 3) a soda can\n" +
      "an old newspaper\n" +
      "an old newspaper\n" +
      "a pair of old brown flipflops\n")
  end

  it "can parse big inventory" do
    lore =
    "You are carrying:\n"+
    "( 2) a Daisy 5000 assault rifle\n"+
    "( 2) a small disposable flashlight\n"+
    "( 2) a dirty map\n"+
    "a Survival Guide for you to EXAMINE\n"+
    "an old newspaper\n"+
    "an old brown shirt\n"+
    "( 2) an Emergency MRE\n"+
    "a stuffed beaver\n"+
    "a combat canteen\n"+
    "a pair of old brown flipflops\n"+
    "a soda can"


    strategy = double('Strategy')

    bot = Bot.new(nil, nil)
    bot.strategy = strategy

    # Going west
    expect(strategy).to receive(:update).with(
        {:inventory =>
             {:soda => 3, :newspaper => 1, :flip => 1, :shard => 15}
        })

    bot.parse_lore(lore)

  end

end
