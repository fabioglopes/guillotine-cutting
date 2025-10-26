require "test_helper"

class SheetTest < ActiveSupport::TestCase
  def setup
    @project = Project.create!(name: "Test Project", cutting_width: 3)
    @sheet = @project.sheets.build(
      label: "MDF 15mm",
      width: 2000,
      height: 1500,
      thickness: 15,
      quantity: 2
    )
  end

  def teardown
    @project.destroy
  end

  test "should be valid with valid attributes" do
    assert @sheet.valid?
  end

  test "should belong to project" do
    assert_respond_to @sheet, :project
  end

  test "should validate presence of label" do
    @sheet.label = nil
    assert_not @sheet.valid?
  end

  test "should validate numericality of width" do
    @sheet.width = nil
    assert @sheet.valid? # width can be nil (optional)
    
    @sheet.width = 0
    assert_not @sheet.valid?
    
    @sheet.width = -10
    assert_not @sheet.valid?
    
    @sheet.width = 2000
    assert @sheet.valid?
  end

  test "should validate numericality of height" do
    @sheet.height = nil
    assert @sheet.valid? # height can be nil (optional)
    
    @sheet.height = 0
    assert_not @sheet.valid?
    
    @sheet.height = -10
    assert_not @sheet.valid?
    
    @sheet.height = 1500
    assert @sheet.valid?
  end

  test "should validate numericality of quantity" do
    @sheet.quantity = nil
    assert @sheet.valid? # quantity can be nil (optional)
    
    @sheet.quantity = 0
    assert_not @sheet.valid?
    
    @sheet.quantity = -1
    assert_not @sheet.valid?
    
    @sheet.quantity = 5
    assert @sheet.valid?
  end

  test "should set default quantity to 1" do
    sheet = Sheet.new(label: "Test", width: 1000, height: 800)
    assert_equal 1, sheet.quantity
  end

  test "should allow thickness to be nil" do
    @sheet.thickness = nil
    assert @sheet.valid?
  end

  test "should save with valid attributes" do
    assert @sheet.save
  end

  test "should be destroyed when project is destroyed" do
    @sheet.save!
    
    assert_difference "Sheet.count", -1 do
      @project.destroy
    end
  end

  test "should accept decimal values for dimensions" do
    @sheet.width = 2000.5
    @sheet.height = 1500.75
    @sheet.thickness = 15.5
    
    assert @sheet.valid?
    @sheet.save!
    @sheet.reload
    
    assert_equal 2000.5, @sheet.width
    assert_equal 1500.75, @sheet.height
    assert_equal 15.5, @sheet.thickness
  end

  test "should handle large dimensions" do
    @sheet.width = 10000
    @sheet.height = 8000
    
    assert @sheet.valid?
  end
end

