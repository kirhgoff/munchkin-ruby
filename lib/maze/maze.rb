require './lib/maze/direction'
require './lib/maze/position'

def cell(*more)
  Cell.new(more)
end

def block
  Block.new
end

def plain
  Plain.new
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

  def find_path(from, destination)
    visited = []
    trail = []
    index = 0
    position = from

    while position != destination
      cell = cell_at(position)
      visited.push(position)
      where_to_go = cell.exits.map{|direction| position.move(direction)} - visited
      if !where_to_go.empty?
        trail.push(position)
        position = where_to_go.first
        index += 1
      else
        position = trail.pop
        index -= 1
        if index <= 0
          break
        end
      end
    end

    convert_to_path(trail.push(position))
  end

  def convert_to_path(trail)
    return [] if trail.empty? || trail.length == 1
    path = []
    trail.drop(1).reduce(trail.first) do |previous,next_one|
      dx = next_one.x - previous.x
      dy = next_one.y - previous.y
      raise ArgumentError.new("Invalid trail #{trail}") if dx != 0 && dy != 0
      direction = if dx == 1
        :east
      elsif dx == -1
        :west
      elsif dy == 1
        :south
      elsif dy == -1
        :north
      else
        raise ArgumentError.new("Invalid trail #{trail}")
      end
      path.push(direction)
      next_one
    end
    path
  end

end
