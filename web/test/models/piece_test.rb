require "test_helper"

class PieceTest < ActiveSupport::TestCase
  def setup
    @project = Project.create!(name: "Test Project", cutting_width: 3)
    @piece = @project.pieces.build(
      label: "Mesa",
      width: 1200,
      height: 800,
      thickness: 18,
      quantity: 2
    )
  end

  def teardown
    @project.destroy
  end

  test "should be valid with valid attributes" do
    assert @piece.valid?
  end

  test "should belong to project" do
    assert_respond_to @piece, :project
  end

  test "should validate presence of label" do
    @piece.label = nil
    assert_not @piece.valid?
  end

  test "should validate numericality of width" do
    @piece.width = nil
    assert @piece.valid? # width can be nil (optional)
    
    @piece.width = 0
    assert_not @piece.valid?
    
    @piece.width = -10
    assert_not @piece.valid?
    
    @piece.width = 1200
    assert @piece.valid?
  end

  test "should validate numericality of height" do
    @piece.height = nil
    assert @piece.valid? # height can be nil (optional)
    
    @piece.height = 0
    assert_not @piece.valid?
    
    @piece.height = -10
    assert_not @piece.valid?
    
    @piece.height = 800
    assert @piece.valid?
  end

  test "should validate numericality of quantity" do
    @piece.quantity = nil
    assert @piece.valid? # quantity can be nil (optional)
    
    @piece.quantity = 0
    assert_not @piece.valid?
    
    @piece.quantity = -1
    assert_not @piece.valid?
    
    @piece.quantity = 5
    assert @piece.valid?
  end

  test "should set default quantity to 1" do
    piece = Piece.new(label: "Test", width: 500, height: 400)
    assert_equal 1, piece.quantity
  end

  test "should allow thickness to be nil" do
    @piece.thickness = nil
    assert @piece.valid?
  end

  test "should save with valid attributes" do
    assert @piece.save
  end

  test "should be destroyed when project is destroyed" do
    @piece.save!
    
    assert_difference "Piece.count", -1 do
      @project.destroy
    end
  end

  test "should accept decimal values for dimensions" do
    @piece.width = 1200.5
    @piece.height = 800.75
    @piece.thickness = 18.5
    
    assert @piece.valid?
    @piece.save!
    @piece.reload
    
    assert_equal 1200.5, @piece.width
    assert_equal 800.75, @piece.height
    assert_equal 18.5, @piece.thickness
  end

  test "should handle various piece sizes" do
    sizes = [
      [10, 10],
      [100, 50],
      [1000, 2000],
      [5000, 3000]
    ]
    
    sizes.each do |width, height|
      piece = @project.pieces.build(
        label: "Test #{width}x#{height}",
        width: width,
        height: height,
        quantity: 1
      )
      assert piece.valid?, "Piece #{width}x#{height} should be valid"
    end
  end

  test "should handle multiple pieces with same label" do
    @piece.save!
    
    piece2 = @project.pieces.build(
      label: "Mesa",  # Same label as @piece
      width: 1000,
      height: 600,
      quantity: 1
    )
    
    assert piece2.valid?
    assert piece2.save
  end
end

