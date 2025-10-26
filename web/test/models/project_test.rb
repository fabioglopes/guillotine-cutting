require "test_helper"

class ProjectTest < ActiveSupport::TestCase
  def setup
    @project = Project.new(
      name: "Test Project",
      cutting_width: 3.0,
      allow_rotation: true
    )
  end

  test "should be valid with valid attributes" do
    assert @project.valid?
  end

  test "should require name" do
    @project.name = nil
    assert_not @project.valid?
    assert_includes @project.errors[:name], "can't be blank"
  end

  test "should require cutting_width" do
    @project.cutting_width = nil
    assert_not @project.valid?
    assert_includes @project.errors[:cutting_width], "can't be blank"
  end

  test "should require cutting_width to be greater than zero" do
    @project.cutting_width = 0
    assert_not @project.valid?
    
    @project.cutting_width = -1
    assert_not @project.valid?
    
    @project.cutting_width = 0.1
    assert @project.valid?
  end

  test "should default status to not_started" do
    project = Project.create!(
      name: "New Project",
      cutting_width: 3.0
    )
    assert_equal "not_started", project.status
    project.destroy
  end

  test "should default allow_rotation to false" do
    project = Project.new(name: "Test", cutting_width: 3)
    assert_equal false, project.allow_rotation
  end

  test "should have many sheets" do
    assert_respond_to @project, :sheets
  end

  test "should have many pieces" do
    assert_respond_to @project, :pieces
  end

  test "should accept nested attributes for sheets" do
    project = Project.new(
      name: "Test",
      cutting_width: 3,
      sheets_attributes: [
        { label: "MDF", width: 2000, height: 1500, quantity: 1 }
      ]
    )
    
    assert project.valid?
    project.save!
    assert_equal 1, project.sheets.count
    project.destroy
  end

  test "should accept nested attributes for pieces" do
    project = Project.new(
      name: "Test",
      cutting_width: 3,
      pieces_attributes: [
        { label: "Mesa", width: 1200, height: 800, quantity: 1 }
      ]
    )
    
    assert project.valid?
    project.save!
    assert_equal 1, project.pieces.count
    project.destroy
  end

  test "should allow input_file attachment" do
    assert_respond_to @project, :input_file
  end

  test "should allow result_files attachments" do
    assert_respond_to @project, :result_files
  end

  test "should destroy associated sheets when destroyed" do
    @project.save!
    @project.sheets.create!(label: "Test", width: 1000, height: 800, quantity: 1)
    
    assert_difference "Sheet.count", -1 do
      @project.destroy
    end
  end

  test "should destroy associated pieces when destroyed" do
    @project.save!
    @project.pieces.create!(label: "Test", width: 500, height: 400, quantity: 1)
    
    assert_difference "Piece.count", -1 do
      @project.destroy
    end
  end

  test "should have status enum" do
    project = Project.create!(name: "Test", cutting_width: 3)
    
    project.pending!
    assert project.pending?
    
    project.processing!
    assert project.processing?
    
    project.completed!
    assert project.completed?
    
    project.error!
    assert project.error?
    
    project.destroy
  end

  test "should store efficiency as decimal" do
    @project.save!
    @project.update(efficiency: 85.67)
    @project.reload
    
    assert_equal 85.67, @project.efficiency
    @project.destroy
  end

  test "should handle description" do
    @project.description = "Test description"
    assert @project.valid?
    
    @project.save!
    @project.reload
    assert_equal "Test description", @project.description
    @project.destroy
  end
end

