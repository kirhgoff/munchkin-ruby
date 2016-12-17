require './lib/maze/position'
require './lib/maze/maze'

RSpec.describe Maze do
  describe Cell do
    it "has walls and exits" do
      cell = Cell.new([:west, :north])

      expect(cell.has_wall_at?(:south)).to be_falsey
      expect(cell.has_wall_at?(:north)).to be_truthy

      expect(cell.walls).to contain_exactly(:west, :north)
      expect(cell.exits).to contain_exactly(:east, :south)
    end
  end

  describe Room do
    it "has three walls and one exit" do
      cell = Room.new(:north)
      walls = [:west, :south, :east]
      expect(walls.map{|d| cell.has_wall_at?(d)}.all?).to be_truthy
      expect(cell.has_wall_at?(:north)).to be_falsey

      expect(cell.walls).to match_array(walls)
      expect(cell.exits).to contain_exactly(:north)
    end
  end

  describe Plain do
    it "has no walls" do
      cell = Plain.new
      expect(Direction.all.map{|d| cell.has_wall_at?(d)}.any?).to be_falsey

      expect(cell.walls).to match_array([])
      expect(cell.exits).to match_array(Direction.all)
    end
  end

  describe Block do
    it "has only walls" do
      cell = Block.new
      expect(Direction.all.map{|d| cell.has_wall_at?(d)}.all?).to be_truthy

      expect(cell.walls).to match_array(Direction.all)
      expect(cell.exits).to match_array([])
    end
  end

  describe "Maze" do
    before do
      @maze = Maze.new([
        [cell(:west, :north), cell(:north, :south), cell(:north, :east)],
        [cell(:west, :east), block, cell(:west, :east)],
        [cell(:west, :south), cell(:north, :south), cell(:south, :east)]])
    end

    it "able to find cell by position" do
      expect(@maze.cell_at(position(1, 1))).to be_a(Block)
      expect(@maze.cell_at(position(0, 0)).walls).to contain_exactly(:north, :west)
      expect(@maze.cell_at(position(1, 0)).walls).to contain_exactly(:north, :south)
      expect(@maze.cell_at(position(0, 1)).walls).to contain_exactly(:west, :east)
    end

    it "able to execute path" do
      expect(@maze.run(position(0, 0), [:east])).to eq position(1, 0)
      expect(@maze.run(position(0, 0), [:east, :east])).to eq position(2, 0)
      expect(@maze.run(position(0, 0), [:south, :south])).to eq position(0, 2)

      expect {@maze.run(position(1, 0), [:north])}.to raise_error(ArgumentError)
    end

    it "can convert trail to path" do
      expect(@maze.convert_to_path([position(0, 0)])).to match_array([])

      expect(@maze.convert_to_path([position(0, 0), position(1, 0)]))
          .to contain_exactly(:east)

      expect(@maze.convert_to_path([position(0, 0), position(1, 0), position(2, 0)]))
          .to match_array([:east, :east])

      expect(@maze.convert_to_path([position(0, 0), position(1, 0), position(1, 1)]))
          .to match_array([:east, :south])

      expect {@maze.convert_to_path([position(0, 0), position(1, 1)])}
          .to raise_error(ArgumentError)
    end

    it "finds a path in small maze" do
      small_maze = Maze.new([[room(:east), room(:west)]])
      path = small_maze.find_path(position(0, 0), position(1, 0))
      expect(small_maze.run(position(0,0), path)).to eq position(1, 0)
    end


    it "finds a path in fixture maze" do
      path = @maze.find_path(position(0, 0), position(2, 2))
      expect(@maze.run(position(0,0), path)).to eq position(2, 2)
    end
  end

end