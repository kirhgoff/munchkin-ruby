class Direction
  COUNTERCLOCKWISE = {:south => :east, :north => :west, :east => :north, :west => :south}
  CLOCKWISE = COUNTERCLOCKWISE.invert

  attr_reader :value

  def self.is_valid?(symbol)
    CLOCKWISE.key?(symbol)
  end

  def initialize(value)
    unless CLOCKWISE.key?(value)
      raise ArgumentError, "Cannot accept value #{value}, should be one of #{CLOCKWISE.keys}"
    end
    @value = value
  end

  def turn_left
    Direction.new(COUNTERCLOCKWISE[value])
  end

  def turn_right
    Direction.new(CLOCKWISE[value])
  end

  def to_s
    value.to_s
  end

  def ==(other)
    other != nil && value == other.value
  end

end
