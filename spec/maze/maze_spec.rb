require './lib/maze/maze.rb'

RSpec.describe Maze do
  describe "Cell" do
    it "has walls and exits" do
      cell = Cell.new([:west, :north])

      expect(cell.has_wall_at?(:south)).to be_falsey
      expect(cell.has_wall_at?(:north)).to be_truthy

      expect(cell.walls).to contain_exactly(:west, :north)
      expect(cell.exits).to contain_exactly(:east, :south)
    end
  end

  describe "Room" do
    it "has three walls and one exit" do
      cell = Room.new(:north)
      walls = [:west, :south, :east]
      expect(walls.map{|d| cell.has_wall_at?(d)}.all?).to be_truthy
      expect(cell.has_wall_at?(:north)).to be_falsey

      expect(cell.walls).to match_array(walls)
      expect(cell.exits).to contain_exactly(:north)
    end
  end

  describe "Plain" do
    it "has no walls" do
      cell = Plain.new
      expect(Direction.all.map{|d| cell.has_wall_at?(d)}.any?).to be_falsey

      expect(cell.walls).to match_array([])
      expect(cell.exits).to match_array(Direction.all)
    end
  end

end