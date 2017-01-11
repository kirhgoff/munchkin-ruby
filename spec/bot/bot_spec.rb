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

  def check(inventory, lore_string)
    strategy = double('Strategy')

    bot = Bot.new(nil, nil)
    bot.strategy = strategy

    expect(strategy).to receive(:update).with(inventory)
    bot.parse_lore(lore_string)
  end

  it "can parse inventory" do
    check({:inventory =>
        {:can => 3, :newspaper => 1, :flipflops => 1, :shard => 15}
      },
      "asdasdasdasdas\n"+
      "You are carrying:\n" +
      "(15) a shard of broken glass\n" +
      "( 3) a soda can\n" +
      "an old newspaper\n" +
      "a pair of old brown flipflops\n"
    )
  end

  it "can parse big inventory" do
    check(
      {:inventory =>
        {:rifle => 2, :flashlight => 2, :map => 2, :guide => 1,
        :newspaper => 1, :shirt => 1, :MRE=>2, :beaver=>1,
        :canteen=>1, :flipflops=>1, :can=>1}
      },
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
      "a soda can\n"
    )
  end

  it "can parse big inventory from file" do
    check(
      {:inventory =>
         {:rifle => 2, :flashlight => 2, :map => 2, :guide => 1,
          :newspaper => 1, :shirt => 1, :MRE=>2, :beaver=>1,
          :canteen=>1, :flipflops=>1, :can=>1}
      },
      File.read('./fixtures/inv_sample.txt')
    )
  end

end
