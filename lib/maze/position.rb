require 'maze/direction'

class Position
  attr_reader :x, :y
  def initialize(x, y)
    @x = x
    @y = y
  end

  def move(direction)
    if direction.is_a? Direction
      direction = direction.value
    end
    case direction
      when :north then Position.new(x, y-1)
      when :south then Position.new(x, y+1)
      when :west then Position.new(x-1, y)
      when :east then Position.new(x+1, y)
      else
        raise "Unknown direction " + direction.to_s
    end
  end

  def to_s
    "Pos[#{x}, #{y}]"
  end

  def ==(other)
    other != nil && x == other.x && y == other.y
  end
end