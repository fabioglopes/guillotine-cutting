require "test_helper"

class PieceTest < ActiveSupport::TestCase
  def setup
    @piece = LibPiece.new("P1", 100, 200, 2, "Mesa")
  end

  test "should initialize with correct attributes" do
    assert_equal "P1", @piece.id
    assert_equal 100, @piece.width
    assert_equal 200, @piece.height
    assert_equal 2, @piece.quantity
    assert_equal "Mesa", @piece.label
  end

  test "should use default label if not provided" do
    piece = LibPiece.new("P2", 50, 75, 1)
    assert_equal "Peça P2", piece.label
  end

  test "should store original dimensions" do
    assert_equal 100, @piece.original_width
    assert_equal 200, @piece.original_height
  end

  test "should calculate area correctly" do
    assert_equal 20000, @piece.area
  end

  test "should rotate piece dimensions" do
    @piece.rotate!
    assert_equal 200, @piece.width
    assert_equal 100, @piece.height
  end

  test "should detect if piece is rotated" do
    assert_not @piece.rotated?
    @piece.rotate!
    assert @piece.rotated?
  end

  test "should return correct string representation" do
    assert_match /Mesa/, @piece.to_s
    assert_match /P1/, @piece.to_s
    assert_match /100x200mm/, @piece.to_s
  end

  test "should indicate rotation in string representation" do
    @piece.rotate!
    assert_match /rotacionada/, @piece.to_s
  end

  test "should handle multiple rotations" do
    @piece.rotate!
    @piece.rotate!
    assert_equal 100, @piece.width
    assert_equal 200, @piece.height
    assert_not @piece.rotated?
  end
end

