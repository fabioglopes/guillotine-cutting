# Service to coordinate the cutting optimization process
class OptimizerService
  attr_reader :project, :errors

  def initialize(project)
    @project = project
    @errors = []
  end

  def run_optimization
    begin
      # Clear all existing result files before new optimization
      @project.result_files.purge

      # Capturar log de otimização
      log_buffer = StringIO.new
      original_stdout = $stdout
      $stdout = log_buffer

      # Load sheets and pieces
      sheets = load_sheets
      pieces = load_pieces

      return false if sheets.empty? || pieces.empty?

      # Run primary optimization based on selected algorithm
      algorithm = @project.optimization_algorithm || 'two_stage_guillotine'
      
      case algorithm
      when 'raster_point_dp'
        puts "🧮 Usando Raster Point DP (paper UNICAMP)!"
        primary_optimizer = RasterPointOptimizer.new(sheets, pieces)
      when 'cutting_optimizer'
        puts "📐 Usando Cutting Optimizer (padrão)!"
        primary_optimizer = CuttingOptimizer.new(sheets, pieces)
      else # 'two_stage_guillotine'
        puts "🔪 Usando Two-Stage Guillotine (paper USP)!"
        primary_optimizer = TwoStageGuillotineOptimizer.new(sheets, pieces)
      end
      
      primary_optimizer.optimize(
        allow_rotation: @project.allow_rotation,
        cutting_width: @project.cutting_width || 3
      )
      
      # Restaurar stdout e salvar log
      $stdout = original_stdout
      @project.update(optimization_log: log_buffer.string)

      # Novo: Run alternative optimization with different sorting
      puts "\n=== Executando otimização alternativa ==="
      alternative_optimizer = CuttingOptimizer.new(sheets, pieces)
      alternative_optimizer.optimize(
        allow_rotation: @project.allow_rotation,
        cutting_width: @project.cutting_width || 3
      ) # Assumindo que alternative usa uma variação, ex: different smart_sort_pieces

      # Generate and save results for primary
      generate_and_save_results(primary_optimizer, prefix: 'primary_')

      # Generate and save results for alternative
      generate_and_save_results(alternative_optimizer, prefix: 'alt_')

      # Update project statistics using primary
      update_project_stats(primary_optimizer)
      
      # Save optimization data for primary
      save_optimization_data(primary_optimizer)
      
      # Track inventory usage for primary
      track_inventory_usage(primary_optimizer) if @project.use_inventory?

      true
    rescue => e
      @errors << "Optimization error: #{e.message}"
      Rails.logger.error("Optimization error for project #{@project.id}: #{e.message}\n#{e.backtrace.join("\n")}")
      false
    ensure
      # Garantir que stdout seja sempre restaurado
      $stdout = original_stdout if defined?(original_stdout)
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
    
    if @project.use_inventory?
      # Use inventory sheets with matching thickness
      inventory_sheets = InventorySheet.available
                                       .where(thickness: @project.thickness)
                                       .order(:label)
      inventory_sheets.each_with_index do |inv_sheet, idx|
        inv_sheet.available_quantity.times do |i|
          sheet_id = "INV#{idx + 1}.#{i + 1}"
          # Use the inventory sheet label directly (without appending #N - optimizer adds it)
          sheets << OptimizerSheet.new(sheet_id, inv_sheet.width, inv_sheet.height, inv_sheet.label)
        end
      end
    else
      # Use manually input sheets
      @project.sheets.each_with_index do |sheet_record, idx|
        sheet_record.quantity.times do |i|
          sheet_id = "S#{idx + 1}.#{i + 1}"
          sheet_label = "#{sheet_record.label} ##{i + 1}"
          sheets << OptimizerSheet.new(sheet_id, sheet_record.width, sheet_record.height, sheet_label)
        end
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

  def generate_and_save_results(optimizer, prefix: '')
    # Generate reports
    generator = WebReportGenerator.new(optimizer, @project)
    
    # Generate SVGs
    svg_files = generator.generate_svg_files
    svg_files.each do |filename, content|
      prefixed_filename = "#{prefix}#{filename}"
      @project.result_files.attach(
        io: StringIO.new(content),
        filename: prefixed_filename,
        content_type: 'image/svg+xml'
      )
    end

    # Generate index HTML
    index_html = generator.generate_index_html
    @project.result_files.attach(
      io: StringIO.new(index_html),
      filename: "#{prefix}index.html",
      content_type: 'text/html'
    )

    # Generate print HTML
    print_html = generator.generate_print_html
    @project.result_files.attach(
      io: StringIO.new(print_html),
      filename: "#{prefix}print.html",
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

  def save_optimization_data(optimizer)
    # Serializar dados das sheets usadas para geração posterior de sobras
    sheets_data = optimizer.used_sheets.map do |sheet|
      {
        id: sheet.id,
        width: sheet.width,
        height: sheet.height,
        label: sheet.label,
        cutting_width: sheet.cutting_width || @project.cutting_width || 3,
        placed_pieces: sheet.placed_pieces.map do |pp|
          {
            x: pp[:x],
            y: pp[:y],
            width: pp[:piece].width,
            height: pp[:piece].height,
            rotated: pp[:rotated]
          }
        end
      }
    end
    
    @project.update(optimization_data: sheets_data.to_json)
  end

  def track_inventory_usage(optimizer)
    # Clear previous usages (in case of re-optimization)
    @project.project_inventory_usages.destroy_all
    
    # Group used sheets by their original inventory sheet
    used_sheets_by_label = {}
    
    optimizer.used_sheets.each do |used_sheet|
      # Extract the base label (remove the #N part)
      base_label = used_sheet.label.gsub(/ #\d+$/, '')
      used_sheets_by_label[base_label] ||= 0
      used_sheets_by_label[base_label] += 1
    end
    
    # Track the sheets that will be used (but don't reserve yet)
    used_sheets_by_label.each do |label, quantity|
      inv_sheet = InventorySheet.find_by(label: label)
      next unless inv_sheet
      
      # Just record the usage, don't reserve yet (reservation happens when marked as cut)
      @project.project_inventory_usages.create!(
        inventory_sheet: inv_sheet,
        quantity_used: quantity
      )
    end
  end
end

