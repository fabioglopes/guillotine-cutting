# Otimizador baseado no algoritmo Two-Stage Guillotine Cutting
# Inspirado no paper: "Two-stage two-dimensional guillotine cutting stock problems with usable leftover"
# Andrade, Birgin, Morabito (2013) - USP
#
# Implementação simplificada usando heurística construtiva:
# 1. Primeiro estágio: Cortes horizontais para criar strips (faixas)
# 2. Segundo estágio: Cortes verticais dentro de cada strip
class TwoStageGuillotineOptimizer
  attr_reader :available_sheets, :required_pieces, :used_sheets, :unplaced_pieces
  
  def initialize(available_sheets, required_pieces)
    @available_sheets = available_sheets
    @required_pieces = expand_pieces(required_pieces)
    @used_sheets = []
    @unplaced_pieces = []
  end
  
  def optimize(allow_rotation: true, cutting_width: 3)
    puts "\n=== Otimização Two-Stage Guillotine (baseado em paper USP) ==="
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
      
      # Gerar padrões de corte possíveis e escolher o melhor
      best_pattern = generate_best_cutting_pattern(sheet, pieces_to_place, allow_rotation, cutting_width)
      
      if best_pattern && best_pattern[:pieces].any?
        # Aplicar o padrão de corte
        apply_cutting_pattern(sheet, best_pattern, pieces_to_place, cutting_width)
        
        # Tentar colocar peças restantes em espaços livres
        if pieces_to_place.any?
          puts "  Tentando colocar #{pieces_to_place.length} peça(s) restante(s) em espaços livres..."
          place_remaining_pieces(sheet, pieces_to_place, allow_rotation, cutting_width)
        end
        
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
  
  # Gera o melhor padrão de corte two-stage para a chapa
  def generate_best_cutting_pattern(sheet, pieces_available, allow_rotation, cutting_width)
    puts "  Gerando padrões de corte two-stage..."
    
    # Agrupar peças por altura similar (para formar strips)
    height_groups = group_pieces_by_height(pieces_available, tolerance: 10)
    
    puts "  Grupos de altura identificados: #{height_groups.length}"
    height_groups.each_with_index do |group, i|
      puts "    Grupo #{i+1}: altura ~#{group[:height]}mm, #{group[:pieces].length} peças"
    end
    
    best_pattern = nil
    best_value = -1
    
    # Tentar diferentes combinações de strips (heurística gulosa)
    patterns = generate_strip_patterns(sheet, height_groups, allow_rotation, cutting_width)
    
    patterns.each_with_index do |pattern, idx|
      # Avaliar padrão: maximizar peças colocadas e eficiência
      value = evaluate_pattern(pattern)
      
      if value > best_value
        best_value = value
        best_pattern = pattern
      end
    end
    
    if best_pattern
      puts "  Melhor padrão: #{best_pattern[:strips].length} strips, #{best_pattern[:pieces].length} peças, valor=#{best_value.round(2)}"
    else
      puts "  Nenhum padrão viável encontrado"
    end
    
    best_pattern
  end
  
  # Agrupa peças por altura similar
  def group_pieces_by_height(pieces, tolerance: 50)
    groups = []
    
    pieces.each do |piece|
      height = piece.height
      
      # Procurar grupo existente
      group = groups.find { |g| (g[:height] - height).abs <= tolerance }
      
      if group
        group[:pieces] << piece
        # Atualizar altura do grupo para a média
        group[:height] = (group[:height] + height) / 2.0
      else
        groups << { height: height, pieces: [piece] }
      end
    end
    
    # Ordenar grupos por número de peças (mais peças primeiro) e depois por altura
    groups.sort_by! { |g| [-g[:pieces].length, -g[:height]] }
    groups
  end
  
  # Gera padrões de corte possíveis (strips horizontais)
  def generate_strip_patterns(sheet, height_groups, allow_rotation, cutting_width)
    patterns = []
    
    # Heurística: tentar colocar strips de forma gulosa
    # Começar com grupos maiores
    pattern = { strips: [], pieces: [], efficiency: 0, snapshots: [] }
    current_y = 0
    
    height_groups.each do |group|
      strip_height = group[:height] + cutting_width
      
      # Verificar se strip cabe na chapa
      if current_y + strip_height <= sheet.height
        # Segundo estágio: preencher strip com cortes verticais
        strip_pieces = fill_strip_with_pieces(
          sheet.width, 
          group[:height], 
          group[:pieces], 
          allow_rotation, 
          cutting_width
        )
        
        if strip_pieces.any?
          strip = {
            y: current_y,
            height: group[:height],
            pieces: strip_pieces
          }
          
          pattern[:strips] << strip
          pattern[:pieces].concat(strip_pieces)
          current_y += strip_height
        end
      end
    end
    
    patterns << pattern if pattern[:pieces].any?
    patterns
  end
  
  # Preenche um strip com peças usando cortes verticais (segundo estágio)
  def fill_strip_with_pieces(strip_width, strip_height, available_pieces, allow_rotation, cutting_width)
    placed = []
    current_x = 0
    
    # Ordenar peças por largura decrescente (First Fit Decreasing)
    sorted_pieces = available_pieces.sort_by { |p| -p.width }
    
    sorted_pieces.each do |piece|
      piece_width = piece.width + cutting_width
      piece_height = piece.height + cutting_width
      rotated = false
      
      # Verificar se peça cabe no strip (considerar tolerância de altura)
      # Permitir peças com altura até 20mm diferente do strip
      height_tolerance = 20
      fits_normal = (current_x + piece_width <= strip_width) && 
                    ((piece.height - strip_height).abs <= height_tolerance || piece.height <= strip_height)
      
      fits_rotated = allow_rotation && 
                     (current_x + piece_height <= strip_width) && 
                     ((piece.width - strip_height).abs <= height_tolerance || piece.width <= strip_height)
      
      if fits_normal
        # Cabe sem rotação
        placed << { piece: piece, x: current_x, rotated: false }
        current_x += piece_width
      elsif fits_rotated
        # Cabe com rotação
        piece.rotate!
        placed << { piece: piece, x: current_x, rotated: true }
        current_x += piece_height
      end
    end
    
    placed
  end
  
  # Avalia qualidade de um padrão de corte
  def evaluate_pattern(pattern)
    return 0 if pattern[:pieces].empty?
    
    # Valor = número de peças + bônus por eficiência
    num_pieces = pattern[:pieces].length
    
    # Calcular eficiência aproximada
    total_piece_area = pattern[:pieces].sum { |pp| pp[:piece].area }
    
    # Valor composto: priorizar número de peças, depois eficiência
    value = num_pieces * 1000 + total_piece_area
    value
  end
  
  # Aplica o padrão de corte à chapa
  def apply_cutting_pattern(sheet, pattern, pieces_to_place, cutting_width)
    puts "  Aplicando padrão de corte:"
    
    pattern[:strips].each_with_index do |strip, strip_idx|
      puts "    Strip #{strip_idx + 1} @ y=#{strip[:y]}, altura=#{strip[:height]}mm"
      
      strip[:pieces].each do |pp|
        piece = pp[:piece]
        x = pp[:x]
        y = strip[:y]
        rotated = pp[:rotated]
        
        sheet.add_piece(piece, x, y, rotated)
        pieces_to_place.delete(piece)
        
        puts "      Peça #{piece.id} @ (#{x}, #{y}) #{rotated ? 'rotacionada' : ''} (#{piece.width}x#{piece.height}mm)"
      end
    end
  end
  
  # Tenta colocar peças restantes em espaços livres da chapa
  def place_remaining_pieces(sheet, pieces_to_place, allow_rotation, cutting_width)
    # Calcular área ocupada e encontrar espaços livres
    max_y = sheet.placed_pieces.map { |pp| pp[:y] + pp[:piece].height }.max || 0
    max_x = sheet.placed_pieces.map { |pp| pp[:x] + pp[:piece].width }.max || 0
    
    # Tentar colocar peças no espaço abaixo dos strips
    if max_y + cutting_width < sheet.height
      available_height = sheet.height - max_y - cutting_width
      puts "    Espaço livre abaixo: #{sheet.width}x#{available_height}mm @ y=#{max_y + cutting_width}"
      
      current_x = 0
      pieces_to_place.dup.each do |piece|
        piece_width = piece.width + cutting_width
        piece_height = piece.height + cutting_width
        rotated = false
        
        # Tentar sem rotação
        if current_x + piece_width <= sheet.width && piece.height <= available_height
          sheet.add_piece(piece, current_x, max_y + cutting_width, false)
          pieces_to_place.delete(piece)
          puts "      Peça #{piece.id} colocada @ (#{current_x}, #{max_y + cutting_width}) (#{piece.width}x#{piece.height}mm)"
          current_x += piece_width
        # Tentar com rotação
        elsif allow_rotation && current_x + piece_height <= sheet.width && piece.width <= available_height
          piece.rotate!
          sheet.add_piece(piece, current_x, max_y + cutting_width, true)
          pieces_to_place.delete(piece)
          puts "      Peça #{piece.id} colocada rotacionada @ (#{current_x}, #{max_y + cutting_width}) (#{piece.width}x#{piece.height}mm)"
          current_x += piece_height
        end
      end
    end
    
    # Tentar colocar peças no espaço à direita dos strips
    if max_x + cutting_width < sheet.width && pieces_to_place.any?
      available_width = sheet.width - max_x - cutting_width
      puts "    Espaço livre à direita: #{available_width}x#{sheet.height}mm @ x=#{max_x + cutting_width}"
      
      current_y = 0
      pieces_to_place.dup.each do |piece|
        piece_width = piece.width + cutting_width
        piece_height = piece.height + cutting_width
        
        # Tentar sem rotação
        if piece.width <= available_width && current_y + piece_height <= sheet.height
          sheet.add_piece(piece, max_x + cutting_width, current_y, false)
          pieces_to_place.delete(piece)
          puts "      Peça #{piece.id} colocada @ (#{max_x + cutting_width}, #{current_y}) (#{piece.width}x#{piece.height}mm)"
          current_y += piece_height
        # Tentar com rotação
        elsif allow_rotation && piece.height <= available_width && current_y + piece_width <= sheet.height
          piece.rotate!
          sheet.add_piece(piece, max_x + cutting_width, current_y, true)
          pieces_to_place.delete(piece)
          puts "      Peça #{piece.id} colocada rotacionada @ (#{max_x + cutting_width}, #{current_y}) (#{piece.width}x#{piece.height}mm)"
          current_y += piece_width
        end
      end
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

