require './lib/maze/direction'

class Cell
  attr_reader :walls
  def initialize(walls)
    @walls = walls
  end

  def walls
    @walls
  end

  def exits
    Direction.all - @walls
  end

  def has_wall_at?(direction)
    @walls.include?(direction)
  end
end

class Room < Cell
  def initialize(door)
    super (Direction.all - [door])
  end
end

class Plain < Cell
  def initialize
    super ([])
  end
end


class Maze
  attr_reader :cells
  def initialize(cells)
    @cells = cells
  end
end
