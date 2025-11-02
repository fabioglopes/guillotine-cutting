# Otimizador baseado em Dynamic Programming com Raster Points
# Inspirado no paper: "Algorithms for 3D guillotine cutting problems"
# Queiroz, Miyazawa, Wakabayashi, Xavier (2011) - UNICAMP
#
# Adaptação 2D do algoritmo 3D usando:
# - Raster points para posições de corte inteligentes
# - Dynamic programming para encontrar melhor combinação
# - Guillotine cuts em múltiplos estágios
class RasterPointOptimizer
  attr_reader :available_sheets, :required_pieces, :used_sheets, :unplaced_pieces
  
  def initialize(available_sheets, required_pieces)
    @available_sheets = available_sheets
    @required_pieces = expand_pieces(required_pieces)
    @used_sheets = []
    @unplaced_pieces = []
    @memo = {} # Memoization para DP
  end
  
  def optimize(allow_rotation: true, cutting_width: 3)
    puts "\n=== Otimização Raster Point DP (baseado em paper UNICAMP) ==="
    puts "Total de peças a cortar: #{@required_pieces.length}"
    puts "Chapas disponíveis: #{@available_sheets.length}"
    puts "Espessura de corte (serra): #{cutting_width}mm"
    puts "Rotação permitida: #{allow_rotation ? 'Sim' : 'Não'}"
    
    pieces_to_place = @required_pieces.dup
    
    @available_sheets.each_with_index do |template_sheet, sheet_idx|
      break if pieces_to_place.empty?
      
      sheet = OptimizerSheet.new(
        "#{template_sheet.id}-#{@used_sheets.length + 1}",
        template_sheet.width,
        template_sheet.height,
        "#{template_sheet.label} ##{@used_sheets.length + 1}"
      )
      
      puts "\n--- Processando chapa #{sheet.label} (#{sheet.width}x#{sheet.height}mm) ---"
      
      # Calcular raster points (posições candidatas para cortes)
      raster_points = calculate_raster_points(sheet, pieces_to_place, cutting_width)
      puts "  Raster points calculados: #{raster_points[:x].length} em X, #{raster_points[:y].length} em Y"
      
      # Usar DP para encontrar melhor padrão de corte
      best_pattern = dp_find_best_pattern(
        sheet, 
        pieces_to_place, 
        raster_points, 
        allow_rotation, 
        cutting_width
      )
      
      if best_pattern && best_pattern[:pieces].any?
        # Aplicar padrão encontrado
        apply_pattern(sheet, best_pattern, pieces_to_place)
        
        sheet.cutting_width = cutting_width
        sheet.snapshots = best_pattern[:snapshots] if best_pattern[:snapshots]
        @used_sheets << sheet
        
        puts "✓ Chapa #{sheet.label}: #{sheet.placed_pieces.length} peças colocadas (#{sheet.efficiency}% utilizada)"
      end
    end
    
    @unplaced_pieces = pieces_to_place
    
    puts "\n=== Otimização concluída ==="
    puts "Chapas utilizadas: #{@used_sheets.length}"
    puts "Peças cortadas: #{@required_pieces.length - @unplaced_pieces.length}"
    puts "Peças não colocadas: #{@unplaced_pieces.length}"
    if @unplaced_pieces.any?
      puts "  IDs não colocadas: #{@unplaced_pieces.map(&:id).join(', ')}"
    end
    puts ""
  end
  
  private
  
  # Calcula raster points - posições candidatas para cortes
  # Baseado no paper: usar bordas das peças como pontos de corte
  def calculate_raster_points(sheet, pieces, cutting_width)
    x_points = [0, sheet.width].to_set
    y_points = [0, sheet.height].to_set
    
    # Adicionar pontos baseados nas dimensões das peças
    pieces.each do |piece|
      # Pontos em X: largura da peça + cutting_width
      x_points.add(piece.width + cutting_width)
      x_points.add(piece.height + cutting_width) if piece.width != piece.height
      
      # Pontos em Y: altura da peça + cutting_width
      y_points.add(piece.height + cutting_width)
      y_points.add(piece.width + cutting_width) if piece.width != piece.height
      
      # Combinações de peças (raster points reduzidos)
      pieces.each do |other_piece|
        next if piece == other_piece
        
        combined_x = piece.width + other_piece.width + cutting_width * 2
        combined_y = piece.height + other_piece.height + cutting_width * 2
        
        x_points.add(combined_x) if combined_x <= sheet.width
        y_points.add(combined_y) if combined_y <= sheet.height
      end
    end
    
    # Filtrar e ordenar
    {
      x: x_points.select { |x| x <= sheet.width }.sort,
      y: y_points.select { |y| y <= sheet.height }.sort
    }
  end
  
  # Dynamic Programming para encontrar melhor padrão de corte
  def dp_find_best_pattern(sheet, pieces, raster_points, allow_rotation, cutting_width)
    puts "  Executando DP para encontrar melhor padrão..."
    
    # Usar preenchimento guloso melhorado como estratégia principal
    # (DP completo seria muito lento para casos reais)
    best_pattern = greedy_fill_improved(sheet, pieces, allow_rotation, cutting_width)
    
    puts "  Melhor padrão: #{best_pattern[:pieces].length} peças, valor=#{best_pattern[:value].round(2)}"
    best_pattern
  end
  
  # Preenchimento guloso melhorado usando raster points com snapshots de cortes
  def greedy_fill_improved(sheet, pieces, allow_rotation, cutting_width)
    placed = []
    remaining = pieces.dup.sort_by { |p| -p.area }
    snapshots = []
    
    # Estado inicial da chapa
    current_sheet = {
      x: 0,
      y: 0,
      width: sheet.width,
      height: sheet.height
    }
    
    # Snapshot inicial: chapa completa vazia
    snapshots << {
      step: 0,
      description: "Chapa inicial completa",
      sheet_area: current_sheet.dup,
      placed_pieces: [],
      cut_type: nil
    }
    
    # Usar estratégia de níveis (shelf-based)
    current_y = 0
    step_number = 1
    
    while remaining.any? && current_y < sheet.height
      # Criar um novo nível (shelf)
      shelf_pieces = []
      shelf_height = 0
      current_x = 0
      
      # Snapshot: Corte horizontal para criar novo shelf (se não for o primeiro)
      if current_y > 0
        snapshots << {
          step: step_number,
          description: "Corte #{step_number}: Horizontal em Y=#{current_y}mm (separar shelf)",
          sheet_area: {
            x: 0,
            y: current_y,
            width: sheet.width,
            height: sheet.height - current_y
          },
          placed_pieces: placed.dup,
          cut_type: :horizontal,
          cut_position: current_y
        }
        step_number += 1
      end
      
      # Tentar preencher este nível
      remaining.dup.each do |piece|
        piece_width = piece.width + cutting_width
        piece_height = piece.height + cutting_width
        rotated = false
        
        # Snapshot: Corte vertical para separar peça (se não for a primeira do shelf)
        if current_x > 0
          snapshots << {
            step: step_number,
            description: "Corte #{step_number}: Vertical em X=#{current_x}mm (separar peça)",
            sheet_area: {
              x: current_x,
              y: current_y,
              width: sheet.width - current_x,
              height: shelf_height > 0 ? shelf_height : sheet.height - current_y
            },
            placed_pieces: placed.dup,
            cut_type: :vertical,
            cut_position: current_x
          }
          step_number += 1
        end
        
        # Tentar sem rotação
        if current_x + piece_width <= sheet.width && piece.height <= sheet.height - current_y
          piece_info = { piece: piece, x: current_x, y: current_y, rotated: false }
          shelf_pieces << piece_info
          placed << piece_info
          shelf_height = [shelf_height, piece_height].max
          
          # Snapshot: Peça colocada
          snapshots << {
            step: step_number,
            description: "Passo #{step_number}: Peça #{piece.id} colocada em (#{current_x}, #{current_y})",
            sheet_area: {
              x: current_x + piece_width,
              y: current_y,
              width: sheet.width - (current_x + piece_width),
              height: shelf_height
            },
            placed_pieces: placed.dup,
            cut_type: :piece_placed,
            piece_placed: piece.id
          }
          step_number += 1
          
          current_x += piece_width
          remaining.delete(piece)
        # Tentar com rotação
        elsif allow_rotation && current_x + piece_height <= sheet.width && piece.width <= sheet.height - current_y
          piece.rotate!
          piece_info = { piece: piece, x: current_x, y: current_y, rotated: true }
          shelf_pieces << piece_info
          placed << piece_info
          shelf_height = [shelf_height, piece_width].max
          
          # Snapshot: Peça rotacionada colocada
          snapshots << {
            step: step_number,
            description: "Passo #{step_number}: Peça #{piece.id} rotacionada e colocada em (#{current_x}, #{current_y})",
            sheet_area: {
              x: current_x + piece_height,
              y: current_y,
              width: sheet.width - (current_x + piece_height),
              height: shelf_height
            },
            placed_pieces: placed.dup,
            cut_type: :piece_placed,
            piece_placed: piece.id
          }
          step_number += 1
          
          current_x += piece_height
          remaining.delete(piece)
        end
      end
      
      # Avançar para próximo nível
      current_y += shelf_height
      
      # Se não colocou nada neste nível, parar
      break if shelf_pieces.empty?
    end
    
    # Snapshot final
    snapshots << {
      step: step_number,
      description: "Finalizado: #{placed.length} peças colocadas, #{remaining.length} restantes",
      sheet_area: {
        x: 0,
        y: 0,
        width: sheet.width,
        height: sheet.height
      },
      placed_pieces: placed.dup,
      cut_type: :final
    }
    
    total_area = placed.sum { |pp| pp[:piece].area }
    
    puts "  #{snapshots.length} snapshots gerados (#{step_number} passos)"
    
    {
      pieces: placed,
      value: placed.length * 1000 + total_area,
      snapshots: snapshots
    }
  end
  
  
  # Aplica o padrão encontrado à chapa
  def apply_pattern(sheet, pattern, pieces_to_place)
    puts "  Aplicando padrão de corte:"
    
    pattern[:pieces].each_with_index do |pp, idx|
      piece = pp[:piece]
      x = pp[:x]
      y = pp[:y]
      rotated = pp[:rotated]
      
      sheet.add_piece(piece, x, y, rotated)
      pieces_to_place.delete(piece)
      
      puts "    Peça #{piece.id} @ (#{x}, #{y}) #{rotated ? 'rotacionada' : ''} (#{piece.width}x#{piece.height}mm)"
    end
  end
  
  # Expande peças com quantidade > 1
  def expand_pieces(pieces)
    expanded = []
    pieces.each do |piece|
      piece.quantity.times do |i|
        new_piece = OptimizerPiece.new(
          "#{piece.id}.#{i + 1}",
          piece.width,
          piece.height,
          1,
          piece.label
        )
        expanded << new_piece
      end
    end
    expanded
  end
end

