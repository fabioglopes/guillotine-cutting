require "test_helper"

class SheetTest < ActiveSupport::TestCase
  def setup
    @sheet = Sheet.new("S1", 2000, 1500, "MDF 15mm")
    @piece1 = Piece.new("P1", 500, 300, 1, "Lateral")
    @piece2 = Piece.new("P2", 400, 200, 1, "Prateleira")
  end

  test "should initialize with correct attributes" do
    assert_equal "S1", @sheet.id
    assert_equal 2000, @sheet.width
    assert_equal 1500, @sheet.height
    assert_equal "MDF 15mm", @sheet.label
  end

  test "should use default label if not provided" do
    sheet = Sheet.new("S2", 1000, 800)
    assert_equal "Chapa S2", sheet.label
  end

  test "should start with empty placed_pieces" do
    assert_empty @sheet.placed_pieces
  end

  test "should calculate area correctly" do
    assert_equal 3_000_000, @sheet.area
  end

  test "should add pieces correctly" do
    @sheet.add_piece(@piece1, 0, 0, false)
    assert_equal 1, @sheet.placed_pieces.length
  end

  test "should store piece placement information" do
    @sheet.add_piece(@piece1, 100, 200, true)
    placement = @sheet.placed_pieces.first
    
    assert_equal @piece1, placement[:piece]
    assert_equal 100, placement[:x]
    assert_equal 200, placement[:y]
    assert placement[:rotated]
  end

  test "should calculate used area correctly" do
    @sheet.add_piece(@piece1, 0, 0, false)
    @sheet.add_piece(@piece2, 500, 0, false)
    
    expected_area = (500 * 300) + (400 * 200)
    assert_equal expected_area, @sheet.used_area
  end

  test "should calculate efficiency correctly" do
    @sheet.add_piece(@piece1, 0, 0, false)
    
    expected_efficiency = (150_000.0 / 3_000_000.0 * 100).round(2)
    assert_equal expected_efficiency, @sheet.efficiency
  end

  test "should return zero efficiency when area is zero" do
    sheet = Sheet.new("S3", 0, 0)
    assert_equal 0, sheet.efficiency
  end

  test "should return correct string representation" do
    @sheet.add_piece(@piece1, 0, 0, false)
    str = @sheet.to_s
    
    assert_match /MDF 15mm/, str
    assert_match /2000x1500mm/, str
    assert_match /utilizada/, str
  end

  test "should handle multiple pieces" do
    5.times do |i|
      piece = Piece.new("P#{i}", 100, 100, 1)
      @sheet.add_piece(piece, i * 100, 0, false)
    end
    
    assert_equal 5, @sheet.placed_pieces.length
    assert_equal 50_000, @sheet.used_area
  end
end

