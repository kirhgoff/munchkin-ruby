module TestUtils
  def position (x, y)
    Position.new(x, y)
  end

  def direction (v)
    Direction.new(v)
  end

  def cell(*more)
    Cell.new(more)
  end

  def block
    Block.new
  end
end