require "test_helper"

class WebReportGeneratorTest < ActiveSupport::TestCase
  def setup
    @project = Project.create!(
      name: "Test Report Generation",
      cutting_width: 3,
      allow_rotation: true
    )
    
    sheets = [::Sheet.new("S1", 2000, 1500, "MDF 15mm")]
    pieces = [
      ::Piece.new("P1", 800, 600, 1, "Tampo"),
      ::Piece.new("P2", 400, 300, 2, "Lateral")
    ]
    
    @optimizer = CuttingOptimizer.new(sheets, pieces)
    
    silence_output do
      @optimizer.optimize(allow_rotation: true, cutting_width: 3)
    end
    
    @generator = WebReportGenerator.new(@optimizer, @project)
  end

  def teardown
    @project.destroy
  end

  test "should initialize with optimizer and project" do
    assert_equal @optimizer, @generator.instance_variable_get(:@optimizer)
    assert_equal @project, @generator.instance_variable_get(:@project)
  end

  test "should generate SVG files" do
    svg_files = @generator.generate_svg_files
    
    assert_instance_of Hash, svg_files
    assert svg_files.keys.any?
    
    svg_files.each do |filename, content|
      assert filename.end_with?('.svg'), "Filename should end with .svg"
      assert content.include?('<?xml'), "Content should be valid SVG"
      assert content.include?('<svg'), "Content should contain SVG tag"
    end
  end

  test "should generate one SVG per used sheet" do
    svg_files = @generator.generate_svg_files
    assert_equal @optimizer.used_sheets.length, svg_files.length
  end

  test "should generate index HTML" do
    html = @generator.generate_index_html
    
    assert_instance_of String, html
    assert html.include?('<!DOCTYPE html'), "Should be valid HTML"
    assert html.include?(@project.name), "Should include project name"
    assert html.include?('Layouts de Corte'), "Should have title"
  end

  test "should generate print HTML" do
    html = @generator.generate_print_html
    
    assert_instance_of String, html
    assert html.include?('<!DOCTYPE html'), "Should be valid HTML"
    assert html.include?(@project.name), "Should include project name"
    assert html.include?('PLANO DE CORTE'), "Should have print title"
  end

  test "should include CSS in generated HTML" do
    html = @generator.generate_index_html
    assert html.include?('<style>'), "Should include CSS"
  end

  test "should include statistics in index HTML" do
    html = @generator.generate_index_html
    
    assert html.include?('Chapas Utilizadas'), "Should show sheets used"
    assert html.include?('Peças Cortadas'), "Should show pieces cut"
    assert html.include?('Eficiência'), "Should show efficiency"
  end

  test "should include sheet information in print HTML" do
    html = @generator.generate_print_html
    
    @optimizer.used_sheets.each do |sheet|
      assert html.include?(sheet.label), "Should include sheet label"
    end
  end

  test "should include piece information in print HTML" do
    html = @generator.generate_print_html
    
    @optimizer.used_sheets.each do |sheet|
      sheet.placed_pieces.each do |pp|
        piece = pp[:piece]
        assert html.include?(piece.id), "Should include piece ID"
      end
    end
  end

  test "should generate valid SVG with proper viewBox" do
    svg_files = @generator.generate_svg_files
    first_svg = svg_files.values.first
    
    assert first_svg.include?('viewBox'), "SVG should have viewBox"
    assert first_svg.include?('xmlns'), "SVG should have XML namespace"
  end

  test "should include piece labels in SVG" do
    svg_files = @generator.generate_svg_files
    first_svg = svg_files.values.first
    
    @optimizer.used_sheets.first.placed_pieces.each do |pp|
      piece = pp[:piece]
      assert first_svg.include?(piece.id), "SVG should include piece ID"
    end
  end

  test "should indicate rotation in HTML report" do
    html = @generator.generate_print_html
    
    # Check if any rotated pieces are indicated
    @optimizer.used_sheets.each do |sheet|
      sheet.placed_pieces.each do |pp|
        if pp[:rotated]
          assert html.include?('ROTACIONADA'), "Should indicate rotation"
        end
      end
    end
  end

  test "should format dimensions correctly" do
    html = @generator.generate_print_html
    
    # Should show dimensions in mm
    assert html.match?(/\d+mm/), "Should display dimensions with mm unit"
  end

  test "should include efficiency in reports" do
    html_index = @generator.generate_index_html
    html_print = @generator.generate_print_html
    
    assert html_index.include?('%'), "Index should show efficiency percentage"
    assert html_print.include?('%'), "Print should show efficiency percentage"
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

