require 'json'

# Gerador de relatórios de corte
class ReportGenerator
  def initialize(optimizer)
    @optimizer = optimizer
  end

  def generate_console_report
    puts "\n" + "=" * 80
    puts "RELATÓRIO DE OTIMIZAÇÃO DE CORTES".center(80)
    puts "=" * 80

    # Resumo
    puts "\n--- RESUMO ---"
    total_pieces = @optimizer.required_pieces.length
    placed_pieces = total_pieces - @optimizer.unplaced_pieces.length
    
    puts "Total de peças necessárias: #{total_pieces}"
    puts "Peças cortadas com sucesso: #{placed_pieces}"
    puts "Peças não alocadas: #{@optimizer.unplaced_pieces.length}"
    puts "Chapas utilizadas: #{@optimizer.used_sheets.length}"
    
    total_area = @optimizer.used_sheets.sum(&:area)
    used_area = @optimizer.used_sheets.sum(&:used_area)
    overall_efficiency = total_area > 0 ? (used_area.to_f / total_area * 100).round(2) : 0
    puts "Eficiência geral: #{overall_efficiency}%"

    # Detalhes de cada chapa
    @optimizer.used_sheets.each do |sheet|
      puts "\n--- #{sheet.label.upcase} ---"
      puts "Dimensões: #{sheet.width}x#{sheet.height}mm"
      puts "Área total: #{sheet.area}mm²"
      puts "Área utilizada: #{sheet.used_area}mm² (#{sheet.efficiency}%)"
      puts "Peças cortadas: #{sheet.placed_pieces.length}"
      puts "\nPeças nesta chapa:"
      
      sheet.placed_pieces.each_with_index do |pp, idx|
        piece = pp[:piece]
        rotation_text = pp[:rotated] ? " [ROTACIONADA]" : ""
        puts "  #{idx + 1}. #{piece.to_s}#{rotation_text}"
        puts "     Posição: X=#{pp[:x]}mm, Y=#{pp[:y]}mm"
      end
      
      puts "\n" + generate_ascii_layout(sheet)
    end

    # Peças não alocadas
    if @optimizer.unplaced_pieces.any?
      puts "\n--- PEÇAS NÃO ALOCADAS ---"
      puts "⚠ As seguintes peças não puderam ser cortadas:"
      @optimizer.unplaced_pieces.each do |piece|
        puts "  - #{piece.to_s}"
      end
      puts "\nSugestão: Adicione mais chapas ou reduza o tamanho das peças."
    end

    puts "\n" + "=" * 80
  end

  def generate_ascii_layout(sheet, scale: 20)
    # Gera uma representação ASCII simplificada do layout
    width_chars = [sheet.width / scale, 40].min
    height_chars = [sheet.height / scale, 20].min
    
    grid = Array.new(height_chars) { Array.new(width_chars, '.') }
    
    sheet.placed_pieces.each_with_index do |pp, idx|
      piece = pp[:piece]
      char = (idx % 26 + 65).chr # A, B, C, ...
      
      x_start = (pp[:x].to_f / sheet.width * width_chars).to_i
      y_start = (pp[:y].to_f / sheet.height * height_chars).to_i
      x_end = ((pp[:x] + piece.width).to_f / sheet.width * width_chars).to_i
      y_end = ((pp[:y] + piece.height).to_f / sheet.height * height_chars).to_i
      
      # Limita aos bounds
      x_start = [[x_start, 0].max, width_chars - 1].min
      y_start = [[y_start, 0].max, height_chars - 1].min
      x_end = [[x_end, 0].max, width_chars - 1].min
      y_end = [[y_end, 0].max, height_chars - 1].min
      
      # Preenche apenas as bordas para visualizar melhor
      (x_start..x_end).each do |x|
        grid[y_start][x] = char if y_start < height_chars
        grid[y_end][x] = char if y_end < height_chars
      end
      
      (y_start..y_end).each do |y|
        grid[y][x_start] = char if x_start < width_chars
        grid[y][x_end] = char if x_end < width_chars
      end
    end
    
    result = "Layout simplificado (escala ~1:#{scale}):\n"
    result += "+" + "-" * width_chars + "+\n"
    grid.each do |row|
      result += "|" + row.join + "|\n"
    end
    result += "+" + "-" * width_chars + "+\n"
    result
  end

  def generate_json_report(filename = 'cutting_report.json')
    report = {
      summary: {
        total_pieces: @optimizer.required_pieces.length,
        placed_pieces: @optimizer.required_pieces.length - @optimizer.unplaced_pieces.length,
        unplaced_pieces: @optimizer.unplaced_pieces.length,
        sheets_used: @optimizer.used_sheets.length,
        overall_efficiency: calculate_overall_efficiency
      },
      sheets: @optimizer.used_sheets.map { |sheet| sheet_to_hash(sheet) },
      unplaced_pieces: @optimizer.unplaced_pieces.map { |piece| piece_to_hash(piece) }
    }

    File.write(filename, JSON.pretty_generate(report))
    puts "\n✓ Relatório JSON salvo em: #{filename}"
  end

  def generate_svg_report(output_dir = 'output')
    require 'fileutils'
    FileUtils.mkdir_p(output_dir)

    @optimizer.used_sheets.each_with_index do |sheet, idx|
      filename = "#{output_dir}/sheet_#{idx + 1}.svg"
      generate_svg_layout(sheet, filename)
      puts "✓ Layout SVG salvo em: #{filename}"
    end
  end

  private

  def calculate_overall_efficiency
    total_area = @optimizer.used_sheets.sum(&:area)
    return 0 if total_area == 0
    used_area = @optimizer.used_sheets.sum(&:used_area)
    (used_area.to_f / total_area * 100).round(2)
  end

  def sheet_to_hash(sheet)
    {
      id: sheet.id,
      label: sheet.label,
      dimensions: { width: sheet.width, height: sheet.height },
      area: sheet.area,
      used_area: sheet.used_area,
      efficiency: sheet.efficiency,
      pieces: sheet.placed_pieces.map do |pp|
        {
          piece: piece_to_hash(pp[:piece]),
          position: { x: pp[:x], y: pp[:y] },
          rotated: pp[:rotated]
        }
      end
    }
  end

  def piece_to_hash(piece)
    {
      id: piece.id,
      label: piece.label,
      dimensions: { width: piece.width, height: piece.height },
      original_dimensions: { width: piece.original_width, height: piece.original_height },
      area: piece.area
    }
  end

  def generate_svg_layout(sheet, filename)
    scale = 0.5 # pixels per mm
    width = sheet.width * scale
    height = sheet.height * scale
    
    svg = <<~SVG
      <?xml version="1.0" encoding="UTF-8"?>
      <svg xmlns="http://www.w3.org/2000/svg" width="#{width + 100}" height="#{height + 100}" viewBox="0 0 #{width + 100} #{height + 100}">
        <style>
          .sheet { fill: #f5f5f5; stroke: #333; stroke-width: 2; }
          .piece { fill: #4CAF50; stroke: #2E7D32; stroke-width: 1; opacity: 0.7; }
          .piece:hover { opacity: 1; }
          .label { font-family: Arial; font-size: 12px; fill: #000; }
          .title { font-family: Arial; font-size: 16px; font-weight: bold; fill: #333; }
        </style>
        
        <text x="10" y="25" class="title">#{sheet.label} - #{sheet.width}x#{sheet.height}mm (#{sheet.efficiency}% utilizada)</text>
        
        <rect x="10" y="40" width="#{width}" height="#{height}" class="sheet"/>
    SVG

    colors = ['#4CAF50', '#2196F3', '#FFC107', '#E91E63', '#9C27B0', '#00BCD4', '#FF5722', '#795548']
    
    sheet.placed_pieces.each_with_index do |pp, idx|
      piece = pp[:piece]
      x = 10 + pp[:x] * scale
      y = 40 + pp[:y] * scale
      w = piece.width * scale
      h = piece.height * scale
      color = colors[idx % colors.length]
      
      svg += <<~PIECE
        <rect x="#{x}" y="#{y}" width="#{w}" height="#{h}" fill="#{color}" stroke="#000" stroke-width="1" opacity="0.7"/>
        <text x="#{x + 5}" y="#{y + 15}" class="label">#{piece.id}</text>
        <text x="#{x + 5}" y="#{y + 30}" class="label" font-size="10">#{piece.width}x#{piece.height}</text>
      PIECE
    end

    svg += "  </svg>"
    
    File.write(filename, svg)
  end
end

