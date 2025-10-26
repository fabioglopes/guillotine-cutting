# Service to coordinate the cutting optimization process
class OptimizerService
  attr_reader :project, :errors

  def initialize(project)
    @project = project
    @errors = []
  end

  def run_optimization
    begin
      # Load sheets and pieces
      sheets = load_sheets
      pieces = load_pieces

      return false if sheets.empty? || pieces.empty?

      # Run optimization
      optimizer = CuttingOptimizer.new(sheets, pieces)
      optimizer.optimize(
        allow_rotation: @project.allow_rotation,
        cutting_width: @project.cutting_width || 3
      )

      # Generate and save results
      generate_and_save_results(optimizer)

      # Update project statistics
      update_project_stats(optimizer)

      true
    rescue => e
      @errors << "Optimization error: #{e.message}"
      Rails.logger.error("Optimization error for project #{@project.id}: #{e.message}\n#{e.backtrace.join("\n")}")
      false
    end
  end

  def parse_uploaded_file
    return false unless @project.input_file.attached?

    file_path = ActiveStorage::Blob.service.path_for(@project.input_file.key)
    extension = File.extname(@project.input_file.filename.to_s).downcase

    case extension
    when '.yml', '.yaml'
      parse_yaml_file(file_path)
    when '.step', '.stp'
      parse_step_file(file_path)
    else
      @errors << "Unsupported file format: #{extension}"
      false
    end
  end

  private

  def load_sheets
    sheets = []
    @project.sheets.each_with_index do |sheet_record, idx|
      sheet_record.quantity.times do |i|
        sheet_id = "S#{idx + 1}.#{i + 1}"
        sheet_label = "#{sheet_record.label} ##{i + 1}"
        sheets << OptimizerSheet.new(sheet_id, sheet_record.width, sheet_record.height, sheet_label)
      end
    end
    sheets
  end

  def load_pieces
    pieces = []
    @project.pieces.each_with_index do |piece_record, idx|
      piece_id = "P#{idx + 1}"
      pieces << OptimizerPiece.new(
        piece_id,
        piece_record.width,
        piece_record.height,
        piece_record.quantity,
        piece_record.label
      )
    end
    pieces
  end

  def generate_and_save_results(optimizer)
    # Clear existing result files
    @project.result_files.purge

    # Generate reports
    generator = WebReportGenerator.new(optimizer, @project)
    
    # Generate SVGs
    svg_files = generator.generate_svg_files
    svg_files.each do |filename, content|
      @project.result_files.attach(
        io: StringIO.new(content),
        filename: filename,
        content_type: 'image/svg+xml'
      )
    end

    # Generate index HTML
    index_html = generator.generate_index_html
    @project.result_files.attach(
      io: StringIO.new(index_html),
      filename: 'index.html',
      content_type: 'text/html'
    )

    # Generate print HTML
    print_html = generator.generate_print_html
    @project.result_files.attach(
      io: StringIO.new(print_html),
      filename: 'print.html',
      content_type: 'text/html'
    )
  end

  def update_project_stats(optimizer)
    total_pieces = optimizer.required_pieces.length
    placed_pieces = total_pieces - optimizer.unplaced_pieces.length
    
    total_area = optimizer.used_sheets.sum(&:area)
    used_area = optimizer.used_sheets.sum(&:used_area)
    overall_efficiency = total_area > 0 ? (used_area.to_f / total_area * 100).round(2) : 0

    @project.update!(
      status: 'completed',
      sheets_used: optimizer.used_sheets.length,
      pieces_placed: placed_pieces,
      pieces_total: total_pieces,
      efficiency: overall_efficiency
    )
  end

  def parse_yaml_file(file_path)
    loader = InputLoader.new
    data = loader.load_file(file_path)

    unless data
      @errors.concat(loader.errors)
      return false
    end

    # Clear existing sheets and pieces
    @project.sheets.destroy_all
    @project.pieces.destroy_all

    # Create sheets from YAML
    data[:sheets].group_by { |s| [s.width, s.height, s.label] }.each do |group, sheets|
      sheet = sheets.first
      @project.sheets.create!(
        label: sheet.label,
        width: sheet.width,
        height: sheet.height,
        quantity: sheets.length
      )
    end

    # Create pieces from YAML
    data[:pieces].each do |piece|
      @project.pieces.create!(
        label: piece.label,
        width: piece.width,
        height: piece.height,
        quantity: piece.quantity
      )
    end

    true
  rescue => e
    @errors << "Error parsing YAML: #{e.message}"
    false
  end

  def parse_step_file(file_path)
    parser = StepParser.new(file_path)
    
    unless parser.parse
      @errors.concat(parser.errors)
      return false
    end

    if parser.parts.empty?
      @errors << "No parts found in STEP file"
      return false
    end

    # Clear existing pieces
    @project.pieces.destroy_all

    # Group by thickness
    pieces_by_thickness = parser.group_by_thickness

    # Create sheets for each thickness
    pieces_by_thickness.keys.sort.each do |thickness|
      @project.sheets.create!(
        label: "MDF #{thickness}mm Sheet",
        width: 2750,
        height: 1850,
        thickness: thickness,
        quantity: 3
      )
    end

    # Create pieces
    pieces_by_thickness.each do |thickness, pieces|
      pieces.each do |piece_data|
        @project.pieces.create!(
          label: piece_data[:label],
          width: piece_data[:width],
          height: piece_data[:height],
          thickness: piece_data[:thickness],
          quantity: 1
        )
      end
    end

    true
  rescue => e
    @errors << "Error parsing STEP: #{e.message}"
    false
  end
end

