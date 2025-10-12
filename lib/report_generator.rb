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

  def generate_svg_report(auto_open = true, output_dir = 'output')
    require 'fileutils'
    FileUtils.mkdir_p(output_dir)

    puts "\n--- GERANDO LAYOUTS SVG ---"
    @optimizer.used_sheets.each_with_index do |sheet, idx|
      filename = "#{output_dir}/sheet_#{idx + 1}.svg"
      generate_svg_layout(sheet, filename)
      puts "  ✓ #{sheet.label}: #{filename}"
    end
    
    # Gera um índice HTML para visualizar todos os SVGs
    index_path = File.join(output_dir, 'index.html')
    generate_html_index(output_dir)
    puts "  ✓ Índice HTML: #{index_path}"
    
    # Abre automaticamente no navegador
    if auto_open
      if open_in_browser(index_path)
        puts "\n🌐 Abrindo navegador com os layouts..."
      else
        puts "\n💡 Abra #{index_path} no seu navegador para visualizar todos os layouts!"
      end
    else
      puts "\n💡 Abra #{index_path} no seu navegador para visualizar todos os layouts!"
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
    # Calcula escala dinâmica para caber bem na tela
    max_width = 1200
    max_height = 800
    scale_w = max_width.to_f / sheet.width
    scale_h = max_height.to_f / sheet.height
    scale = [scale_w, scale_h, 0.8].min # Limita escala máxima
    
    width = sheet.width * scale
    height = sheet.height * scale
    padding = 80
    legend_width = 300
    
    svg_width = width + padding * 2 + legend_width
    svg_height = height + padding * 2
    
    svg = <<~SVG
      <?xml version="1.0" encoding="UTF-8"?>
      <svg xmlns="http://www.w3.org/2000/svg" width="#{svg_width}" height="#{svg_height}" viewBox="0 0 #{svg_width} #{svg_height}">
        <defs>
          <pattern id="grid" width="#{50 * scale}" height="#{50 * scale}" patternUnits="userSpaceOnUse">
            <path d="M #{50 * scale} 0 L 0 0 0 #{50 * scale}" fill="none" stroke="#ddd" stroke-width="0.5"/>
          </pattern>
          <filter id="shadow">
            <feDropShadow dx="2" dy="2" stdDeviation="3" flood-opacity="0.3"/>
          </filter>
        </defs>
        
        <style>
          .sheet { fill: url(#grid); stroke: #333; stroke-width: 3; filter: url(#shadow); }
          .piece { stroke: #000; stroke-width: 1.5; opacity: 0.85; cursor: pointer; }
          .piece:hover { opacity: 1; stroke-width: 2.5; }
          .label-id { font-family: 'Arial Black', Arial, sans-serif; font-size: 14px; font-weight: bold; fill: #000; }
          .label-size { font-family: Arial, sans-serif; font-size: 11px; fill: #222; }
          .label-name { font-family: Arial, sans-serif; font-size: 10px; fill: #444; }
          .title { font-family: Arial, sans-serif; font-size: 22px; font-weight: bold; fill: #1a1a1a; }
          .subtitle { font-family: Arial, sans-serif; font-size: 14px; fill: #555; }
          .legend-title { font-family: Arial, sans-serif; font-size: 14px; font-weight: bold; fill: #333; }
          .legend-text { font-family: Arial, sans-serif; font-size: 11px; fill: #555; }
          .dimension-line { stroke: #666; stroke-width: 1; stroke-dasharray: 3,3; }
          .dimension-text { font-family: Arial, sans-serif; font-size: 10px; fill: #666; }
          .rotation-indicator { font-family: Arial, sans-serif; font-size: 16px; fill: #E91E63; }
        </style>
        
        <!-- Título -->
        <text x="#{padding}" y="35" class="title">#{sheet.label}</text>
        <text x="#{padding}" y="55" class="subtitle">Dimensões: #{sheet.width}x#{sheet.height}mm | Aproveitamento: #{sheet.efficiency}%</text>
        
        <!-- Dimensões da chapa -->
        <line x1="#{padding}" y1="#{padding + height + 15}" x2="#{padding + width}" y2="#{padding + height + 15}" class="dimension-line"/>
        <text x="#{padding + width/2}" y="#{padding + height + 30}" class="dimension-text" text-anchor="middle">#{sheet.width}mm</text>
        
        <line x1="#{padding - 15}" y1="#{padding}" x2="#{padding - 15}" y2="#{padding + height}" class="dimension-line"/>
        <text x="#{padding - 25}" y="#{padding + height/2}" class="dimension-text" text-anchor="middle" transform="rotate(-90 #{padding - 25} #{padding + height/2})">#{sheet.height}mm</text>
        
        <!-- Chapa principal -->
        <rect x="#{padding}" y="#{padding}" width="#{width}" height="#{height}" class="sheet"/>
    SVG

    colors = [
      '#4CAF50', '#2196F3', '#FFC107', '#E91E63', '#9C27B0', 
      '#00BCD4', '#FF5722', '#795548', '#607D8B', '#8BC34A',
      '#FF9800', '#9E9E9E', '#3F51B5', '#F44336', '#CDDC39'
    ]
    
    # Legenda
    svg += "\n        <!-- Legenda -->\n"
    svg += "        <rect x=\"#{padding + width + 40}\" y=\"#{padding}\" width=\"#{legend_width - 60}\" height=\"#{[sheet.placed_pieces.length * 35 + 40, height].min}\" fill=\"#fafafa\" stroke=\"#ccc\" stroke-width=\"1\" rx=\"5\"/>\n"
    svg += "        <text x=\"#{padding + width + 55}\" y=\"#{padding + 25}\" class=\"legend-title\">Peças Cortadas</text>\n"
    
    sheet.placed_pieces.each_with_index do |pp, idx|
      piece = pp[:piece]
      # Corrigir alinhamento: começar do padding, sem offset adicional
      x = padding + pp[:x] * scale
      y = padding + pp[:y] * scale
      w = piece.width * scale
      h = piece.height * scale
      color = colors[idx % colors.length]
      
      # Peça no layout
      svg += "\n        <!-- Peça #{idx + 1}: #{piece.label} -->\n"
      svg += "        <rect x=\"#{x}\" y=\"#{y}\" width=\"#{w}\" height=\"#{h}\" fill=\"#{color}\" class=\"piece\"/>\n"
      
      # Labels dentro da peça (se couber)
      if w > 60 && h > 40
        label_x = x + w/2
        label_y = y + h/2 - 10
        
        svg += "        <text x=\"#{label_x}\" y=\"#{label_y}\" class=\"label-id\" text-anchor=\"middle\">#{piece.id}</text>\n"
        svg += "        <text x=\"#{label_x}\" y=\"#{label_y + 18}\" class=\"label-size\" text-anchor=\"middle\">#{piece.width}×#{piece.height}mm</text>\n"
        
        # Indicador de rotação
        if pp[:rotated]
          svg += "        <text x=\"#{x + 5}\" y=\"#{y + 20}\" class=\"rotation-indicator\">↻</text>\n"
        end
      else
        # Se for muito pequena, só mostra o ID
        svg += "        <text x=\"#{x + w/2}\" y=\"#{y + h/2 + 5}\" class=\"label-id\" text-anchor=\"middle\" font-size=\"10\">#{piece.id}</text>\n"
      end
      
      # Item na legenda
      legend_y = padding + 45 + idx * 35
      if legend_y < padding + height - 10
        svg += "        <rect x=\"#{padding + width + 55}\" y=\"#{legend_y - 12}\" width=\"20\" height=\"20\" fill=\"#{color}\" stroke=\"#000\" stroke-width=\"1\"/>\n"
        
        piece_label = piece.label.length > 20 ? piece.label[0..17] + "..." : piece.label
        rotation_mark = pp[:rotated] ? " ↻" : ""
        
        svg += "        <text x=\"#{padding + width + 82}\" y=\"#{legend_y}\" class=\"legend-text\">#{piece.id}: #{piece_label}#{rotation_mark}</text>\n"
        svg += "        <text x=\"#{padding + width + 82}\" y=\"#{legend_y + 12}\" class=\"legend-text\" font-size=\"9\">#{piece.width}×#{piece.height}mm @ (#{pp[:x]}, #{pp[:y]})</text>\n"
      end
    end

    # Estatísticas no rodapé da legenda
    legend_stats_y = padding + [sheet.placed_pieces.length * 35 + 60, height - 80].min
    if legend_stats_y > 0
      svg += "\n        <!-- Estatísticas -->\n"
      svg += "        <line x1=\"#{padding + width + 55}\" y1=\"#{legend_stats_y}\" x2=\"#{padding + width + legend_width - 75}\" y2=\"#{legend_stats_y}\" stroke=\"#ccc\" stroke-width=\"1\"/>\n"
      svg += "        <text x=\"#{padding + width + 55}\" y=\"#{legend_stats_y + 20}\" class=\"legend-text\" font-weight=\"bold\">Total de peças: #{sheet.placed_pieces.length}</text>\n"
      svg += "        <text x=\"#{padding + width + 55}\" y=\"#{legend_stats_y + 35}\" class=\"legend-text\">Área utilizada: #{sheet.used_area}mm²</text>\n"
      svg += "        <text x=\"#{padding + width + 55}\" y=\"#{legend_stats_y + 50}\" class=\"legend-text\">Área desperdiçada: #{sheet.area - sheet.used_area}mm²</text>\n"
    end

    svg += "      </svg>"
    
    File.write(filename, svg)
  end

  def generate_html_index(output_dir)
    html = <<~HTML
      <!DOCTYPE html>
      <html lang="pt-BR">
      <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Layouts de Corte - Otimizador</title>
        <style>
          * { margin: 0; padding: 0; box-sizing: border-box; }
          body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            padding: 20px;
            min-height: 100vh;
          }
          .container {
            max-width: 1400px;
            margin: 0 auto;
            background: white;
            border-radius: 15px;
            padding: 30px;
            box-shadow: 0 20px 60px rgba(0,0,0,0.3);
          }
          h1 {
            color: #333;
            margin-bottom: 10px;
            font-size: 2.5em;
          }
          .subtitle {
            color: #666;
            margin-bottom: 30px;
            font-size: 1.1em;
          }
          .summary {
            background: #f8f9fa;
            padding: 20px;
            border-radius: 10px;
            margin-bottom: 30px;
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 15px;
          }
          .stat {
            text-align: center;
            padding: 15px;
            background: white;
            border-radius: 8px;
            box-shadow: 0 2px 5px rgba(0,0,0,0.1);
          }
          .stat-value {
            font-size: 2em;
            font-weight: bold;
            color: #667eea;
          }
          .stat-label {
            color: #666;
            margin-top: 5px;
          }
          .sheets-grid {
            display: flex;
            flex-direction: column;
            gap: 30px;
            max-width: 100%;
          }
          .sheet-card {
            background: #f8f9fa;
            border-radius: 10px;
            padding: 20px;
            box-shadow: 0 4px 6px rgba(0,0,0,0.1);
            transition: box-shadow 0.3s ease;
            width: 100%;
            page-break-inside: avoid;
          }
          .sheet-card:hover {
            box-shadow: 0 8px 15px rgba(0,0,0,0.2);
          }
          .sheet-title {
            font-size: 1.3em;
            font-weight: bold;
            color: #333;
            margin-bottom: 10px;
          }
          .sheet-info {
            color: #666;
            margin-bottom: 15px;
            font-size: 0.95em;
          }
          .svg-container {
            background: white;
            border-radius: 8px;
            padding: 10px;
            border: 2px solid #ddd;
          }
          .svg-container svg {
            width: 100%;
            height: auto;
          }
          .print-btn {
            display: inline-block;
            margin-top: 10px;
            padding: 8px 16px;
            background: #667eea;
            color: white;
            text-decoration: none;
            border-radius: 5px;
            font-weight: bold;
            transition: background 0.3s ease;
          }
          .print-btn:hover {
            background: #5568d3;
          }
          @media print {
            body { background: white; padding: 0; }
            .container { box-shadow: none; }
            .sheet-card { page-break-inside: avoid; }
            .print-btn { display: none; }
          }
          .footer {
            margin-top: 40px;
            text-align: center;
            color: #999;
            padding-top: 20px;
            border-top: 1px solid #ddd;
          }
        </style>
      </head>
      <body>
        <div class="container">
          <h1>🪚 Layouts de Corte Otimizados</h1>
          <p class="subtitle">Relatório gerado pelo Otimizador de Cortes</p>
          
          <div class="summary">
            <div class="stat">
              <div class="stat-value">#{@optimizer.used_sheets.length}</div>
              <div class="stat-label">Chapas Utilizadas</div>
            </div>
            <div class="stat">
              <div class="stat-value">#{@optimizer.required_pieces.length - @optimizer.unplaced_pieces.length}</div>
              <div class="stat-label">Peças Cortadas</div>
            </div>
            <div class="stat">
              <div class="stat-value">#{calculate_overall_efficiency}%</div>
              <div class="stat-label">Eficiência Geral</div>
            </div>
            <div class="stat">
              <div class="stat-value">#{@optimizer.unplaced_pieces.length}</div>
              <div class="stat-label">Peças Não Alocadas</div>
            </div>
          </div>
          
          <div class="sheets-grid">
    HTML

    @optimizer.used_sheets.each_with_index do |sheet, idx|
      svg_file = "sheet_#{idx + 1}.svg"
      html += <<~SHEET
            <div class="sheet-card">
              <div class="sheet-title">#{sheet.label}</div>
              <div class="sheet-info">
                📐 Dimensões: #{sheet.width}×#{sheet.height}mm<br>
                📦 Peças: #{sheet.placed_pieces.length}<br>
                ✅ Aproveitamento: #{sheet.efficiency}%
              </div>
              <div class="svg-container">
                <object data="#{svg_file}" type="image/svg+xml" style="width: 100%; height: auto;"></object>
              </div>
              <a href="#{svg_file}" download class="print-btn">⬇ Baixar SVG</a>
            </div>
      SHEET
    end

    html += <<~HTML
          </div>
          
          <div class="footer">
            Gerado pelo Otimizador de Cortes de Madeira • #{Time.now.strftime('%d/%m/%Y às %H:%M')}
          </div>
        </div>
      </body>
      </html>
    HTML

    File.write("#{output_dir}/index.html", html)
  end

  def open_in_browser(filepath)
    # Converte para caminho absoluto
    absolute_path = File.absolute_path(filepath)
    
    # Detecta o sistema operacional e usa o comando apropriado
    case RUBY_PLATFORM
    when /linux/
      # Linux: tenta vários comandos comuns
      system("xdg-open '#{absolute_path}' 2>/dev/null") ||
      system("sensible-browser '#{absolute_path}' 2>/dev/null") ||
      system("firefox '#{absolute_path}' 2>/dev/null") ||
      system("google-chrome '#{absolute_path}' 2>/dev/null") ||
      system("chromium '#{absolute_path}' 2>/dev/null")
    when /darwin/
      # macOS
      system("open '#{absolute_path}'")
    when /mswin|mingw|cygwin/
      # Windows
      system("start '#{absolute_path}'")
    else
      false
    end
  end
end

