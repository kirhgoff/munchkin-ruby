require './lib/maze/position'
require './spec/model_helpers'

include TestUtils

RSpec.describe Position do
  before do
    @position = position(0, 0)
  end

  it "moves to correct position" do
    expect(@position.move(:east)).to eq position(1, 0)
    expect(@position.move(:west)).to eq position(-1, 0)
    expect(@position.move(:south)).to eq position(0, 1)
    expect(@position.move(:north)).to eq position(0, -1)
  end

end