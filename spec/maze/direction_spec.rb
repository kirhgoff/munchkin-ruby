require './lib/maze/direction'

RSpec.describe Direction do

  it "can detect movement commands" do
    expect(Direction.parse('w')).to eq :west
    expect(Direction.parse('we')).to eq :west
    expect(Direction.parse('wes')).to eq :west
    expect(Direction.parse('west')).to eq :west
    expect(Direction.parse('wEs')).to eq :west

    expect(Direction.parse('no')).to eq :north
    expect(Direction.parse('eas')).to eq :east

    expect(Direction.parse('pasta')).to be_nil
    expect(Direction.parse(nil)).to be_nil
    expect(Direction.parse("")).to be_nil
  end

end