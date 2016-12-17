require './lib/maze/direction'
require './lib/maze/position'

def cell(*more)
  Cell.new(more)
end

def block
  Block.new
end

def room(exit)
  Room.new(exit)
end

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

class Block < Cell
  def initialize
    super (Direction.all)
  end
end


class Maze
  attr_reader :cells
  def initialize(cells)
    # TODO add maze validation
    @cells = cells
  end

  def cell_at(position)
    cells[position.y][position.x]
  end

  def wander(from)
    cell_at(from).exits
  end

  def run(position, path)
    path.reduce(position) do |current,direction|
      cell = cell_at(current)
      if cell.has_wall_at?(direction)
        raise ArgumentError.new("there is no path to #{direction} on #{current}")
      end
      current.move(direction)
    end
  end

  def path(from, destination)
    visited = []
    trail = []
    position = from

    while position != destination
      cell = cell_at(position)
      where_to_go = cell.exits - visited
      if where_to_go.empty?

      else

      end
    end
  end

end
