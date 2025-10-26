# Web-adapted report generator for Rails
class WebReportGenerator
  def initialize(optimizer, project)
    @optimizer = optimizer
    @project = project
  end

  def generate_svg_files
    svg_files = {}
    
    @optimizer.used_sheets.each_with_index do |sheet, idx|
      filename = "sheet_#{idx + 1}.svg"
      svg_files[filename] = generate_svg_layout(sheet)
    end
    
    svg_files
  end

  def generate_index_html
    # Generate a simple HTML index
    html = <<~HTML
      <!DOCTYPE html>
      <html lang="pt-BR">
      <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Layouts de Corte - #{@project.name}</title>
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
          h1 { color: #333; margin-bottom: 10px; font-size: 2.5em; }
          .subtitle { color: #666; margin-bottom: 30px; font-size: 1.1em; }
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
          .stat-label { color: #666; margin-top: 5px; }
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
          }
          .sheet-title {
            font-size: 1.3em;
            font-weight: bold;
            color: #333;
            margin-bottom: 10px;
          }
          .svg-container {
            background: white;
            border-radius: 8px;
            padding: 10px;
            border: 2px solid #ddd;
          }
          .svg-container svg { width: 100%; height: auto; }
        </style>
      </head>
      <body>
        <div class="container">
          <h1>🪚 Layouts de Corte Otimizados</h1>
          <p class="subtitle">#{@project.name}</p>
          
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
              <div class="svg-container">
                <p>Ver arquivo: #{svg_file}</p>
              </div>
            </div>
      SHEET
    end

    html += <<~HTML
          </div>
        </div>
      </body>
      </html>
    HTML

    html
  end

  def generate_print_html
    # Generate print-optimized HTML similar to CLI version
    html = <<~HTML
      <!DOCTYPE html>
      <html lang="pt-BR">
      <head>
        <meta charset="UTF-8">
        <title>Plano de Corte - #{@project.name}</title>
        <style>
          @page { size: A4; margin: 15mm; }
          * { margin: 0; padding: 0; box-sizing: border-box; }
          body { font-family: Arial, sans-serif; font-size: 12pt; color: #000; line-height: 1.5; }
          
          .page { page-break-after: always; }
          .page:last-child { page-break-after: auto; }
          
          .print-header {
            border-bottom: 3px solid #000;
            padding-bottom: 10px;
            margin-bottom: 15px;
          }
          .print-header h1 { font-size: 22pt; font-weight: bold; margin-bottom: 5px; }
          .print-header .meta { font-size: 11pt; color: #555; }
          
          .summary-box {
            background: #f5f5f5;
            border: 2px solid #333;
            padding: 12px;
            margin-bottom: 15px;
            border-radius: 5px;
          }
          .summary-box h2 { font-size: 14pt; margin-bottom: 8px; }
          .summary-stats {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 10px;
          }
          .stat-item {
            background: white;
            padding: 8px;
            border-radius: 3px;
            text-align: center;
            border: 1px solid #ddd;
          }
          .stat-label { font-size: 10pt; color: #666; margin-bottom: 3px; }
          .stat-value { font-size: 18pt; font-weight: bold; color: #333; }
          
          .instructions {
            background: #fffbea;
            border: 2px solid #f0ad4e;
            padding: 10px;
            margin-bottom: 15px;
            border-radius: 5px;
          }
          .instructions h3 { font-size: 13pt; margin-bottom: 8px; color: #856404; }
          .instructions ul { margin-left: 20px; font-size: 11pt; }
          .instructions li { margin-bottom: 3px; }
          
          .sheet-section {
            page-break-before: always;
            page-break-inside: avoid;
          }
          .sheet-section:first-of-type { page-break-before: auto; }
          
          .sheet-header {
            background: #333;
            color: white;
            padding: 10px 12px;
            margin-bottom: 10px;
            font-size: 16pt;
            font-weight: bold;
            border-radius: 3px;
          }
          
          .sheet-info {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 10px;
            margin-bottom: 15px;
          }
          .info-box {
            background: #f8f9fa;
            padding: 8px;
            border: 1px solid #ddd;
            border-radius: 3px;
          }
          .info-label { font-size: 10pt; color: #666; margin-bottom: 2px; }
          .info-value { font-size: 14pt; font-weight: bold; }
          
          .pieces-table {
            width: 100%;
            border-collapse: collapse;
            margin-bottom: 15px;
            font-size: 11pt;
          }
          .pieces-table th, .pieces-table td { 
            padding: 8px 6px; 
            border: 1px solid #333; 
            text-align: left; 
          }
          .pieces-table th { 
            background: #333; 
            color: white; 
            font-weight: bold;
            font-size: 12pt;
          }
          .pieces-table tr:nth-child(even) { background: #f9f9f9; }
          .pieces-table td:first-child { text-align: center; font-size: 14pt; }
          .rotated { color: #d32f2f; font-weight: bold; }
          
          .cutting-diagram {
            border: 2px solid #000;
            padding: 10px;
            background: white;
            margin-top: 15px;
            margin-bottom: 15px;
            page-break-inside: avoid;
          }
          
          .diagram-title {
            font-size: 13pt;
            font-weight: bold;
            margin-bottom: 10px;
            text-align: center;
            color: #333;
          }
          
          .svg-container {
            text-align: center;
            background: white;
          }
          
          .svg-container svg {
            max-width: 100%;
            height: auto;
            border: 1px solid #ccc;
          }
          
          .footer-chapa {
            margin-top: 15px;
            padding-top: 10px;
            border-top: 1px solid #ccc;
            font-size: 10pt;
            text-align: center;
            color: #666;
          }
          
          @media print {
            body { print-color-adjust: exact; -webkit-print-color-adjust: exact; }
          }
          
          @media screen {
            body { max-width: 210mm; margin: 20px auto; background: #fff; padding: 20px; box-shadow: 0 0 10px rgba(0,0,0,0.1); }
            .print-button {
              position: fixed;
              top: 20px;
              right: 20px;
              background: #4CAF50;
              color: white;
              border: none;
              padding: 12px 24px;
              font-size: 11pt;
              font-weight: bold;
              border-radius: 5px;
              cursor: pointer;
              box-shadow: 0 4px 8px rgba(0,0,0,0.2);
              z-index: 1000;
            }
            .print-button:hover { background: #45a049; }
            .no-print { display: block; }
          }
          
          @media print {
            .no-print { display: none !important; }
          }
        </style>
      </head>
      <body>
        <button class="print-button no-print" onclick="window.print()">🖨️ IMPRIMIR</button>
        
        <div class="page">
          <div class="print-header">
            <h1>🪚 PLANO DE CORTE DE CHAPAS</h1>
            <div class="meta">
              Projeto: #{@project.name} | 
              Gerado em: #{Time.now.strftime('%d/%m/%Y às %H:%M')} | 
              Modo: #{@project.guillotine_mode ? '🔪 Guilhotina' : '📐 Normal'}
            </div>
          </div>
          
          <div class="summary-box">
            <h2>📊 Resumo do Projeto</h2>
            <div class="summary-stats">
              <div class="stat-item">
                <div class="stat-label">Chapas Utilizadas</div>
                <div class="stat-value">#{@optimizer.used_sheets.length}</div>
              </div>
              <div class="stat-item">
                <div class="stat-label">Peças Cortadas</div>
                <div class="stat-value">#{@optimizer.required_pieces.length - @optimizer.unplaced_pieces.length}/#{@optimizer.required_pieces.length}</div>
              </div>
              <div class="stat-item">
                <div class="stat-label">Eficiência Geral</div>
                <div class="stat-value">#{calculate_overall_efficiency}%</div>
              </div>
              <div class="stat-item">
                <div class="stat-label">Não Alocadas</div>
                <div class="stat-value">#{@optimizer.unplaced_pieces.length}</div>
              </div>
            </div>
          </div>
          
          <div class="instructions">
            <h3>📋 Instruções para Marcenaria:</h3>
            <ul>
              <li>✓ Confira todas as medidas antes de iniciar os cortes</li>
              <li>✓ Considere a espessura do corte (serra): #{@project.cutting_width}mm</li>
              <li>✓ Peças marcadas com "↻" devem ser rotacionadas 90°</li>
              <li>✓ Use as caixas ☐ para marcar as peças já cortadas</li>
              <li>✓ As coordenadas (X,Y) indicam o ponto inicial (canto inferior esquerdo)</li>
              #{@project.guillotine_mode ? '<li>✓ <strong>Modo Guilhotina:</strong> Peças agrupadas para minimizar cortes</li>' : ''}
            </ul>
          </div>
        </div>
    HTML

    @optimizer.used_sheets.each_with_index do |sheet, idx|
      html += <<~SHEET
        
        <div class="sheet-section">
          <div class="sheet-header">CHAPA #{idx + 1}: #{sheet.label}</div>
          
          <div class="sheet-info">
            <div class="info-box">
              <div class="info-label">Dimensões</div>
              <div class="info-value">#{sheet.width} × #{sheet.height} mm</div>
            </div>
            <div class="info-box">
              <div class="info-label">Aproveitamento</div>
              <div class="info-value">#{sheet.efficiency}%</div>
            </div>
            <div class="info-box">
              <div class="info-label">Peças nesta chapa</div>
              <div class="info-value">#{sheet.placed_pieces.length}</div>
            </div>
          </div>
          
          <table class="pieces-table">
            <thead>
              <tr>
                <th>☐</th>
                <th>#</th>
                <th>ID</th>
                <th>Identificação</th>
                <th>Largura</th>
                <th>Altura</th>
                <th>Posição (X,Y)</th>
                <th>Obs.</th>
              </tr>
            </thead>
            <tbody>
      SHEET

      sheet.placed_pieces.each_with_index do |pp, piece_idx|
        piece = pp[:piece]
        rotation_mark = pp[:rotated] ? '<span class="rotated">↻ ROTACIONADA</span>' : ''
        html += <<~PIECE
              <tr>
                <td>☐</td>
                <td>#{piece_idx + 1}</td>
                <td>#{piece.id}</td>
                <td>#{piece.label}</td>
                <td>#{piece.width} mm</td>
                <td>#{piece.height} mm</td>
                <td>(#{pp[:x]}, #{pp[:y]})</td>
                <td>#{rotation_mark}</td>
              </tr>
        PIECE
      end

      html += <<~SHEET_END
            </tbody>
          </table>
          
          <div class="cutting-diagram">
            <div class="diagram-title">DIAGRAMA DE CORTE</div>
            <div class="svg-container">
      SHEET_END
      
      # Embed SVG inline
      svg_content = generate_svg_layout(sheet)
      html += svg_content
      
      html += <<~SHEET_END2
            </div>
          </div>
          
          <div class="footer-chapa">
            Chapa #{idx + 1} de #{@optimizer.used_sheets.length} | 
            Área utilizada: #{sheet.used_area}mm² | 
            Área desperdiçada: #{sheet.area - sheet.used_area}mm²
          </div>
        </div>
      SHEET_END2
    end

    # Página de peças não alocadas (se houver)
    if @optimizer.unplaced_pieces.any?
      html += <<~UNPLACED
        
        <div class="sheet-section">
          <div class="sheet-header" style="background: #c00;">⚠️ PEÇAS NÃO ALOCADAS</div>
          
          <div class="instructions" style="background: #ffcccc; border-color: #c00;">
            <h3>Atenção: As seguintes peças não puderam ser cortadas com as chapas disponíveis:</h3>
          </div>
          
          <table class="pieces-table">
            <thead>
              <tr>
                <th>ID</th>
                <th>Identificação</th>
                <th>Largura</th>
                <th>Altura</th>
                <th>Área</th>
              </tr>
            </thead>
            <tbody>
      UNPLACED

      @optimizer.unplaced_pieces.each do |piece|
        html += <<~UNPLACED_ROW
              <tr>
                <td>#{piece.id}</td>
                <td>#{piece.label}</td>
                <td>#{piece.width} mm</td>
                <td>#{piece.height} mm</td>
                <td>#{piece.area} mm²</td>
              </tr>
        UNPLACED_ROW
      end

      html += <<~UNPLACED_END
            </tbody>
          </table>
          
          <div class="instructions" style="background: #fffacd; border-color: #f0ad4e;">
            <h3>💡 Sugestões:</h3>
            <ul>
              <li>Adicione mais chapas ao projeto</li>
              <li>Verifique se as dimensões das peças estão corretas</li>
              <li>Considere dividir peças grandes em partes menores</li>
            </ul>
          </div>
        </div>
      UNPLACED_END
    end

    html += "</body></html>"
    html
  end

  private

  def generate_svg_layout(sheet)
    # Reuse existing SVG generation logic
    generator = ReportGenerator.new(@optimizer)
    
    # Calcula escala dinâmica para caber bem na tela
    max_width = 1200
    max_height = 800
    scale_w = max_width.to_f / sheet.width
    scale_h = max_height.to_f / sheet.height
    scale = [scale_w, scale_h, 0.8].min
    
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
          .label-id { font-family: 'Arial Black', Arial, sans-serif; font-size: 26px; font-weight: bold; fill: #000; }
          .label-size { font-family: Arial, sans-serif; font-size: 20px; fill: #222; }
          .label-name { font-family: Arial, sans-serif; font-size: 18px; fill: #444; }
          .title { font-family: Arial, sans-serif; font-size: 34px; font-weight: bold; fill: #1a1a1a; }
          .subtitle { font-family: Arial, sans-serif; font-size: 22px; fill: #555; }
          .legend-title { font-family: Arial, sans-serif; font-size: 22px; font-weight: bold; fill: #333; }
          .legend-text { font-family: Arial, sans-serif; font-size: 16px; fill: #555; }
          .dimension-line { stroke: #666; stroke-width: 1; stroke-dasharray: 3,3; }
          .dimension-text { font-family: Arial, sans-serif; font-size: 18px; fill: #666; }
          .rotation-indicator { font-family: Arial, sans-serif; font-size: 26px; fill: #E91E63; }
        </style>
        
        <!-- Título -->
        <text x="#{padding}" y="40" class="title">#{sheet.label}</text>
        <text x="#{padding}" y="65" class="subtitle">Dimensões: #{sheet.width}x#{sheet.height}mm | Aproveitamento: #{sheet.efficiency}%</text>
        
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
    svg += "        <rect x=\"#{padding + width + 40}\" y=\"#{padding}\" width=\"#{legend_width - 60}\" height=\"#{[sheet.placed_pieces.length * 42 + 50, height].min}\" fill=\"#fafafa\" stroke=\"#ccc\" stroke-width=\"1\" rx=\"5\"/>\n"
    svg += "        <text x=\"#{padding + width + 55}\" y=\"#{padding + 30}\" class=\"legend-title\">Peças Cortadas</text>\n"
    
    sheet.placed_pieces.each_with_index do |pp, idx|
      piece = pp[:piece]
      # Coordinates already include cutting width in the bin packer
      x = padding + pp[:x] * scale
      y = padding + pp[:y] * scale
      # Draw piece with actual dimensions (not including cutting width for visual)
      w = piece.width * scale
      h = piece.height * scale
      color = colors[idx % colors.length]
      
      # Peça no layout
      svg += "\n        <!-- Peça #{idx + 1}: #{piece.label} -->\n"
      svg += "        <rect x=\"#{x}\" y=\"#{y}\" width=\"#{w}\" height=\"#{h}\" fill=\"#{color}\" class=\"piece\"/>\n"
      
      # Labels dentro da peça (se couber)
      if w > 80 && h > 50
        label_x = x + w/2
        label_y = y + h/2 - 14
        
        svg += "        <text x=\"#{label_x}\" y=\"#{label_y}\" class=\"label-id\" text-anchor=\"middle\">#{piece.id}</text>\n"
        svg += "        <text x=\"#{label_x}\" y=\"#{label_y + 28}\" class=\"label-size\" text-anchor=\"middle\">#{piece.width}×#{piece.height}mm</text>\n"
        
        # Indicador de rotação
        if pp[:rotated]
          svg += "        <text x=\"#{x + 8}\" y=\"#{y + 30}\" class=\"rotation-indicator\">↻</text>\n"
        end
      else
        svg += "        <text x=\"#{x + w/2}\" y=\"#{y + h/2 + 7}\" class=\"label-id\" text-anchor=\"middle\" font-size=\"18\">#{piece.id}</text>\n"
      end
      
      # Item na legenda
      legend_y = padding + 52 + idx * 42
      if legend_y < padding + height - 10
        svg += "        <rect x=\"#{padding + width + 55}\" y=\"#{legend_y - 14}\" width=\"24\" height=\"24\" fill=\"#{color}\" stroke=\"#000\" stroke-width=\"1\"/>\n"
        
        piece_label = piece.label.length > 18 ? piece.label[0..15] + "..." : piece.label
        rotation_mark = pp[:rotated] ? " ↻" : ""
        
        svg += "        <text x=\"#{padding + width + 86}\" y=\"#{legend_y}\" class=\"legend-text\">#{piece.id}: #{piece_label}#{rotation_mark}</text>\n"
        svg += "        <text x=\"#{padding + width + 86}\" y=\"#{legend_y + 16}\" class=\"legend-text\" font-size=\"14\">#{piece.width}×#{piece.height}mm @ (#{pp[:x]}, #{pp[:y]})</text>\n"
      end
    end

    # Estatísticas no rodapé da legenda
    legend_stats_y = padding + [sheet.placed_pieces.length * 42 + 70, height - 80].min
    if legend_stats_y > 0
      svg += "\n        <!-- Estatísticas -->\n"
      svg += "        <line x1=\"#{padding + width + 55}\" y1=\"#{legend_stats_y}\" x2=\"#{padding + width + legend_width - 75}\" y2=\"#{legend_stats_y}\" stroke=\"#ccc\" stroke-width=\"1\"/>\n"
      svg += "        <text x=\"#{padding + width + 55}\" y=\"#{legend_stats_y + 24}\" class=\"legend-text\" font-weight=\"bold\">Total de peças: #{sheet.placed_pieces.length}</text>\n"
      svg += "        <text x=\"#{padding + width + 55}\" y=\"#{legend_stats_y + 42}\" class=\"legend-text\">Área utilizada: #{sheet.used_area}mm²</text>\n"
      svg += "        <text x=\"#{padding + width + 55}\" y=\"#{legend_stats_y + 60}\" class=\"legend-text\">Área desperdiçada: #{sheet.area - sheet.used_area}mm²</text>\n"
    end

    svg += "      </svg>"
    
    svg
  end

  def calculate_overall_efficiency
    total_area = @optimizer.used_sheets.sum(&:area)
    return 0 if total_area == 0
    used_area = @optimizer.used_sheets.sum(&:used_area)
    (used_area.to_f / total_area * 100).round(2)
  end
end

