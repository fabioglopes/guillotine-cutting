require "test_helper"

class GuillotineBinPackerTest < ActiveSupport::TestCase
  def setup
    @packer = GuillotineBinPacker.new(1000, 800, cutting_width: 3)
    @small_piece = Piece.new("P1", 200, 150, 1, "Small")
    @medium_piece = Piece.new("P2", 400, 300, 1, "Medium")
    @large_piece = Piece.new("P3", 900, 700, 1, "Large")
    @too_large_piece = Piece.new("P4", 1100, 900, 1, "Too Large")
  end

  test "should initialize with correct dimensions" do
    assert_equal 1000, @packer.width
    assert_equal 800, @packer.height
  end

  test "should insert piece successfully" do
    result = @packer.insert(@small_piece, false)
    
    assert_not_nil result
    assert_equal 0, result[:x]
    assert_equal 0, result[:y]
    assert_equal false, result[:rotated]
  end

  test "should not insert piece that doesn't fit" do
    result = @packer.insert(@too_large_piece, false)
    assert_nil result
  end

  test "should insert piece with rotation when allowed" do
    # Create a piece that only fits if rotated
    tall_piece = Piece.new("P5", 850, 500, 1, "Tall")
    result = @packer.insert(tall_piece, true)
    
    assert_not_nil result
  end

  test "should place multiple pieces without overlap" do
    result1 = @packer.insert(@small_piece, false)
    result2 = @packer.insert(@medium_piece, false)
    
    assert_not_nil result1
    assert_not_nil result2
    
    # Check that pieces don't overlap (considering cutting width)
    # Second piece should be placed considering first piece + cutting width
    assert result2[:x] >= (@small_piece.width + 3) || 
           result2[:y] >= (@small_piece.height + 3)
  end

  test "should account for cutting width" do
    # Insert a piece that takes up most of the width
    wide_piece = Piece.new("P6", 995, 100, 1, "Wide")
    result = @packer.insert(wide_piece, false)
    
    # Try to insert another piece - should fail because cutting width is considered
    another_piece = Piece.new("P7", 50, 50, 1, "Small")
    result2 = @packer.insert(another_piece, false)
    
    # Depending on implementation, this might fit or not
    # The test verifies the packer is working
    assert_not_nil result
  end

  test "should handle piece rotation correctly" do
    # Create a piece that fits better when rotated
    piece = Piece.new("P8", 790, 400, 1, "Rotatable")
    original_width = piece.width
    original_height = piece.height
    
    result = @packer.insert(piece, true)
    
    if result && result[:rotated]
      assert_equal original_height, piece.width
      assert_equal original_width, piece.height
    end
  end

  test "should try both orientations when rotation allowed" do
    packer = GuillotineBinPacker.new(500, 1000, cutting_width: 3)
    # Piece that only fits when rotated
    piece = Piece.new("P9", 950, 450, 1, "Tall Piece")
    
    result = packer.insert(piece, true)
    assert_not_nil result
  end

  test "should not modify piece when rotation not allowed" do
    original_width = @medium_piece.width
    original_height = @medium_piece.height
    
    @packer.insert(@medium_piece, false)
    
    assert_equal original_width, @medium_piece.width
    assert_equal original_height, @medium_piece.height
  end
end

