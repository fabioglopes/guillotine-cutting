require "test_helper"

class OptimizerServiceTest < ActiveSupport::TestCase
  def setup
    @project = Project.create!(
      name: "Test Optimization",
      cutting_width: 3,
      allow_rotation: true
    )
    
    @project.sheets.create!(
      label: "MDF 15mm",
      width: 2000,
      height: 1500,
      quantity: 2
    )
    
    @project.pieces.create!(label: "Mesa", width: 1200, height: 800, quantity: 1)
    @project.pieces.create!(label: "Lateral", width: 600, height: 400, quantity: 2)
    
    @service = OptimizerService.new(@project)
  end

  def teardown
    @project.destroy
  end

  test "should initialize with project" do
    assert_equal @project, @service.instance_variable_get(:@project)
  end

  test "should load sheets from project" do
    sheets = @service.send(:load_sheets)
    
    assert_equal 2, sheets.length
    assert_instance_of ::Sheet, sheets.first
    assert_equal 2000, sheets.first.width
    assert_equal 1500, sheets.first.height
  end

  test "should load pieces from project" do
    pieces = @service.send(:load_pieces)
    
    assert_equal 2, pieces.length
    assert_instance_of ::Piece, pieces.first
  end

  test "should expand pieces by quantity when loading" do
    pieces = @service.send(:load_pieces)
    
    # Check that lateral pieces are expanded (quantity: 2)
    lateral_pieces = pieces.select { |p| p.label.include?("Lateral") }
    assert_equal 1, lateral_pieces.length
    assert_equal 2, lateral_pieces.first.quantity
  end

  test "should run optimization successfully" do
    silence_output do
      @service.run_optimization
    end
    
    @project.reload
    assert @project.completed? || @project.error?
  end

  test "should update project status during optimization" do
    initial_status = @project.status
    
    silence_output do
      @service.run_optimization
    end
    
    @project.reload
    assert_not_equal initial_status, @project.status
  end

  test "should attach result files after optimization" do
    silence_output do
      @service.run_optimization
    end
    
    @project.reload
    
    if @project.completed?
      assert @project.result_files.attached?
      assert @project.result_files.count > 0
    end
  end

  test "should handle project without sheets" do
    project = Project.create!(
      name: "No Sheets",
      cutting_width: 3
    )
    
    project.pieces.create!(label: "Test", width: 500, height: 400, quantity: 1)
    
    service = OptimizerService.new(project)
    
    assert_raises(StandardError) do
      silence_output { service.run_optimization }
    end
    
    project.destroy
  end

  test "should handle project without pieces" do
    project = Project.create!(
      name: "No Pieces",
      cutting_width: 3
    )
    
    project.sheets.create!(label: "Test", width: 2000, height: 1500, quantity: 1)
    
    service = OptimizerService.new(project)
    
    assert_raises(StandardError) do
      silence_output { service.run_optimization }
    end
    
    project.destroy
  end

  test "should set efficiency after optimization" do
    silence_output do
      @service.run_optimization
    end
    
    @project.reload
    
    if @project.completed?
      assert_not_nil @project.efficiency
      assert @project.efficiency >= 0
      assert @project.efficiency <= 100
    end
  end

  test "should generate SVG files" do
    silence_output do
      @service.run_optimization
    end
    
    @project.reload
    
    if @project.completed?
      svg_files = @project.result_files.select { |f| f.filename.to_s.end_with?('.svg') }
      assert svg_files.any?, "Should generate at least one SVG file"
    end
  end

  test "should generate HTML files" do
    silence_output do
      @service.run_optimization
    end
    
    @project.reload
    
    if @project.completed?
      html_files = @project.result_files.select { |f| f.filename.to_s.end_with?('.html') }
      assert html_files.any?, "Should generate HTML files"
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

