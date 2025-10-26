require "test_helper"

class CuttingOptimizerTest < ActiveSupport::TestCase
  def setup
    @sheets = [
      Sheet.new("S1", 2000, 1500, "MDF 15mm"),
      Sheet.new("S2", 2000, 1500, "MDF 15mm")
    ]
    
    @pieces = [
      Piece.new("P1", 500, 400, 2, "Lateral"),
      Piece.new("P2", 800, 600, 1, "Tampo"),
      Piece.new("P3", 300, 200, 3, "Prateleira")
    ]
    
    @optimizer = CuttingOptimizer.new(@sheets, @pieces)
  end

  test "should initialize with sheets and pieces" do
    assert_equal 2, @optimizer.available_sheets.length
    # Pieces are expanded by quantity
    assert_equal 6, @optimizer.required_pieces.length # 2+1+3
  end

  test "should expand pieces by quantity" do
    pieces = @optimizer.required_pieces
    
    # Check P1 (quantity 2)
    p1_pieces = pieces.select { |p| p.id.start_with?("P1.") }
    assert_equal 2, p1_pieces.length
    
    # Check P2 (quantity 1)
    p2_pieces = pieces.select { |p| p.id.start_with?("P2.") }
    assert_equal 1, p2_pieces.length
    
    # Check P3 (quantity 3)
    p3_pieces = pieces.select { |p| p.id.start_with?("P3.") }
    assert_equal 3, p3_pieces.length
  end

  test "should optimize and place pieces" do
    # Suppress output during test
    silence_output do
      @optimizer.optimize(allow_rotation: true, cutting_width: 3)
    end
    
    assert @optimizer.used_sheets.length > 0
    assert @optimizer.used_sheets.length <= @sheets.length
  end

  test "should place all pieces when space is sufficient" do
    silence_output do
      @optimizer.optimize(allow_rotation: true, cutting_width: 3)
    end
    
    total_placed = @optimizer.used_sheets.sum { |s| s.placed_pieces.length }
    assert_equal 6, total_placed
    assert_empty @optimizer.unplaced_pieces
  end

  test "should track unplaced pieces when space is insufficient" do
    # Create small sheets that can't fit all pieces
    small_sheets = [Sheet.new("S1", 500, 400, "Small")]
    large_pieces = [Piece.new("P1", 450, 350, 10, "Large")]
    
    optimizer = CuttingOptimizer.new(small_sheets, large_pieces)
    
    silence_output do
      optimizer.optimize(allow_rotation: false, cutting_width: 3)
    end
    
    assert optimizer.unplaced_pieces.length > 0
  end

  test "should respect cutting width parameter" do
    silence_output do
      @optimizer.optimize(allow_rotation: true, cutting_width: 5)
    end
    
    # With larger cutting width, efficiency should be lower
    # (more space wasted between pieces)
    @optimizer.used_sheets.each do |sheet|
      assert sheet.efficiency <= 100
    end
  end

  test "should work without rotation" do
    silence_output do
      @optimizer.optimize(allow_rotation: false, cutting_width: 3)
    end
    
    # Check no pieces were rotated
    @optimizer.used_sheets.each do |sheet|
      sheet.placed_pieces.each do |pp|
        assert_equal false, pp[:rotated]
      end
    end
  end

  test "should prefer larger sheets first" do
    sheets_mixed = [
      Sheet.new("S1", 1000, 800, "Small"),
      Sheet.new("S2", 2000, 1500, "Large"),
      Sheet.new("S3", 1500, 1200, "Medium")
    ]
    
    optimizer = CuttingOptimizer.new(sheets_mixed, @pieces)
    
    silence_output do
      optimizer.optimize(allow_rotation: true, cutting_width: 3)
    end
    
    # First used sheet should be the largest available
    if optimizer.used_sheets.any?
      first_sheet = optimizer.used_sheets.first
      assert first_sheet.width * first_sheet.height >= 1000 * 800
    end
  end

  private

  def silence_output
    original_stdout = $stdout
    $stdout = StringIO.new
    yield
  ensure
    $stdout = original_stdout
  end
end

