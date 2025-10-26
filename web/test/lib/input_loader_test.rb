require "test_helper"
require "tempfile"

class InputLoaderTest < ActiveSupport::TestCase
  def setup
    @loader = InputLoader.new
  end

  def teardown
    # Clean up any temp files
    @temp_file&.close
    @temp_file&.unlink
  end

  test "should initialize with empty errors and warnings" do
    assert_empty @loader.errors
    assert_empty @loader.warnings
  end

  test "should return nil for non-existent file" do
    result = @loader.load_file("non_existent_file.yml")
    assert_nil result
    assert @loader.errors.any?
  end

  test "should load valid YAML file" do
    yaml_content = <<~YAML
      available_sheets:
        - width: 2000
          height: 1500
          quantity: 2
          label: "MDF 15mm"
      
      required_pieces:
        - width: 500
          height: 400
          quantity: 1
          label: "Lateral"
    YAML
    
    @temp_file = Tempfile.new(['test', '.yml'])
    @temp_file.write(yaml_content)
    @temp_file.rewind
    
    result = @loader.load_file(@temp_file.path)
    
    assert_not_nil result
    assert_equal 2, result[:sheets].length
    assert_equal 1, result[:pieces].length
  end

  test "should handle Portuguese keys" do
    yaml_content = <<~YAML
      chapas_disponiveis:
        - largura: 2000
          altura: 1500
          quantidade: 1
          identificacao: "MDF"
      
      pecas_necessarias:
        - largura: 500
          altura: 400
          quantidade: 2
          identificacao: "Peça"
    YAML
    
    @temp_file = Tempfile.new(['test', '.yml'])
    @temp_file.write(yaml_content)
    @temp_file.rewind
    
    result = @loader.load_file(@temp_file.path)
    
    assert_not_nil result
    assert_equal 1, result[:sheets].length
    assert_equal 1, result[:pieces].length
  end

  test "should create Sheet objects correctly" do
    yaml_content = <<~YAML
      available_sheets:
        - width: 2000
          height: 1500
          quantity: 2
          label: "Test Sheet"
          thickness: 15
    YAML
    
    @temp_file = Tempfile.new(['test', '.yml'])
    @temp_file.write(yaml_content)
    @temp_file.rewind
    
    result = @loader.load_file(@temp_file.path)
    
    sheet = result[:sheets].first
    assert_instance_of Sheet, sheet
    assert_equal 2000, sheet.width
    assert_equal 1500, sheet.height
    assert_match /Test Sheet/, sheet.label
  end

  test "should create Piece objects correctly" do
    yaml_content = <<~YAML
      required_pieces:
        - width: 500
          height: 400
          quantity: 3
          label: "Test Piece"
          thickness: 18
    YAML
    
    @temp_file = Tempfile.new(['test', '.yml'])
    @temp_file.write(yaml_content)
    @temp_file.rewind
    
    result = @loader.load_file(@temp_file.path)
    
    piece = result[:pieces].first
    assert_instance_of Piece, piece
    assert_equal 500, piece.width
    assert_equal 400, piece.height
    assert_equal 3, piece.quantity
    assert_match /Test Piece/, piece.label
  end

  test "should generate unique IDs for sheets" do
    yaml_content = <<~YAML
      available_sheets:
        - width: 2000
          height: 1500
          quantity: 3
          label: "MDF"
    YAML
    
    @temp_file = Tempfile.new(['test', '.yml'])
    @temp_file.write(yaml_content)
    @temp_file.rewind
    
    result = @loader.load_file(@temp_file.path)
    
    ids = result[:sheets].map(&:id)
    assert_equal 3, ids.length
    assert_equal 3, ids.uniq.length # All IDs should be unique
  end

  test "should handle missing optional fields" do
    yaml_content = <<~YAML
      available_sheets:
        - width: 2000
          height: 1500
          quantity: 1
      
      required_pieces:
        - width: 500
          height: 400
          quantity: 1
    YAML
    
    @temp_file = Tempfile.new(['test', '.yml'])
    @temp_file.write(yaml_content)
    @temp_file.rewind
    
    result = @loader.load_file(@temp_file.path)
    
    assert_not_nil result
    assert result[:sheets].first.label.present?
    assert result[:pieces].first.label.present?
  end

  test "should add thickness to label when provided" do
    yaml_content = <<~YAML
      required_pieces:
        - width: 500
          height: 400
          quantity: 1
          label: "Mesa"
          thickness: 25
    YAML
    
    @temp_file = Tempfile.new(['test', '.yml'])
    @temp_file.write(yaml_content)
    @temp_file.rewind
    
    result = @loader.load_file(@temp_file.path)
    
    piece = result[:pieces].first
    assert_match /25mm/, piece.label
  end

  test "should reject invalid YAML" do
    @temp_file = Tempfile.new(['test', '.yml'])
    @temp_file.write("invalid: yaml: content: {{")
    @temp_file.rewind
    
    result = @loader.load_file(@temp_file.path)
    
    assert_nil result
    assert @loader.errors.any?
  end

  test "should reject unsupported file formats" do
    @temp_file = Tempfile.new(['test', '.txt'])
    @temp_file.write("some content")
    @temp_file.rewind
    
    result = @loader.load_file(@temp_file.path)
    
    assert_nil result
    assert @loader.errors.any?
    assert @loader.errors.first.include?("Unsupported file format")
  end
end

