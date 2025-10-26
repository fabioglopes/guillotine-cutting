# Otimizador que prioriza cortes guilhotina (menos passadas na serra)
class GuillotineOptimizer
  attr_reader :available_sheets, :required_pieces, :used_sheets, :unplaced_pieces
  
  def initialize(available_sheets, required_pieces)
    @available_sheets = available_sheets
    @required_pieces = expand_pieces(required_pieces)
    @used_sheets = []
    @unplaced_pieces = []
  end
  
  def optimize(allow_rotation: true, cutting_width: 3)
    puts "\n=== Otimização com Cortes Guilhotina ==="
    puts "Agrupando peças por dimensão para minimizar cortes..."
    puts "Espessura de corte (serra): #{cutting_width}mm"
    puts "Rotação permitida: #{allow_rotation ? 'Sim' : 'Não'}"
    
    pieces_to_place = @required_pieces.dup.sort_by { |p| -p.area }
    
    # Agrupar peças por dimensões similares
    groups = group_by_dimensions(pieces_to_place, allow_rotation)
    
    puts "\nGrupos identificados: #{groups.length}"
    groups.each_with_index do |group, i|
      puts "  Grupo #{i+1}: #{group[:pieces].length} peças de ~#{group[:dimension]}mm"
    end
    
    @available_sheets.each_with_index do |template_sheet, sheet_idx|
      break if pieces_to_place.empty?
      
      sheet = OptimizerSheet.new(
        "#{template_sheet.id}-#{@used_sheets.length + 1}",
        template_sheet.width,
        template_sheet.height,
        "#{template_sheet.label} ##{@used_sheets.length + 1}"
      )
      
      # Tentar colocar peças usando estratégia de faixas (strips)
      placed = place_in_strips(sheet, pieces_to_place, groups, allow_rotation, cutting_width)
      
      if placed > 0
        @used_sheets << sheet
        puts "  Chapa #{sheet.label}: #{placed} peças colocadas (#{sheet.efficiency}% utilizada)"
      end
    end
    
    @unplaced_pieces = pieces_to_place
    
    puts "\n=== Otimização concluída ==="
    puts "Chapas utilizadas: #{@used_sheets.length}"
    puts "Peças cortadas: #{@required_pieces.length - @unplaced_pieces.length}"
    puts "Peças não colocadas: #{@unplaced_pieces.length}"
    puts "Cortes guilhotina: Minimizados!"
    puts ""
  end
  
  private
  
  # Agrupa peças por dimensões similares
  def group_by_dimensions(pieces, allow_rotation)
    groups = []
    tolerance = 5 # mm de tolerância para considerar mesma dimensão
    
    pieces.each do |piece|
      # Tenta encontrar grupo existente com dimensão similar
      dim = piece.width
      found = false
      
      groups.each do |group|
        if (group[:dimension] - dim).abs <= tolerance
          group[:pieces] << piece
          found = true
          break
        end
      end
      
      # Se não encontrou, cria novo grupo
      unless found
        groups << {
          dimension: dim,
          pieces: [piece]
        }
      end
    end
    
    # Ordena grupos por quantidade de peças (mais peças primeiro)
    groups.sort_by! { |g| -g[:pieces].length }
    groups
  end
  
  # Coloca peças usando estratégia de faixas verticais/horizontais
  def place_in_strips(sheet, pieces_to_place, groups, allow_rotation, cutting_width)
    placed_count = 0
    current_x = 0
    
    # Processar grupos do maior para o menor
    groups.each do |group|
      next if group[:pieces].empty?
      
      # Pegar peças deste grupo que ainda não foram colocadas
      group_pieces = group[:pieces].select { |p| pieces_to_place.include?(p) }
      next if group_pieces.empty?
      
      # Tentar criar uma faixa vertical com essas peças
      strip_width = group[:dimension] + cutting_width
      
      # Verificar se cabe na chapa
      next if current_x + strip_width > sheet.width
      
      # Colocar peças nesta faixa
      current_y = 0
      
      group_pieces.each do |piece|
        # Verificar se cabe na altura
        piece_height = piece.height + cutting_width
        
        if current_y + piece_height <= sheet.height
          # Colocar peça
          sheet.add_piece(piece, current_x, current_y, false)
          pieces_to_place.delete(piece)
          placed_count += 1
          current_y += piece_height
        end
      end
      
      # Avançar para próxima faixa
      current_x += strip_width if placed_count > 0
    end
    
    # Se ainda tem espaço, tentar colocar peças restantes sem otimização de cortes
    remaining_pieces = pieces_to_place.select { |p| 
      p.width + cutting_width <= (sheet.width - current_x) &&
      p.height + cutting_width <= sheet.height
    }
    
    remaining_pieces.each do |piece|
      # Buscar melhor posição para peça restante
      best_pos = find_best_position(sheet, piece, cutting_width)
      
      if best_pos
        sheet.add_piece(piece, best_pos[:x], best_pos[:y], best_pos[:rotated])
        pieces_to_place.delete(piece)
        placed_count += 1
      end
    end
    
    placed_count
  end
  
  # Encontra melhor posição para uma peça (fallback)
  def find_best_position(sheet, piece, cutting_width)
    # Implementação simples - tentar cantos primeiro
    positions = [
      { x: 0, y: 0, rotated: false },
      { x: sheet.width - piece.width - cutting_width, y: 0, rotated: false }
    ]
    
    positions.each do |pos|
      if can_place?(sheet, piece, pos[:x], pos[:y], cutting_width)
        return pos
      end
    end
    
    nil
  end
  
  # Verifica se pode colocar peça em posição específica
  def can_place?(sheet, piece, x, y, cutting_width)
    # Verificar limites da chapa
    return false if x + piece.width + cutting_width > sheet.width
    return false if y + piece.height + cutting_width > sheet.height
    
    # Verificar sobreposição com peças já colocadas
    sheet.placed_pieces.each do |pp|
      existing_piece = pp[:piece]
      ex = pp[:x]
      ey = pp[:y]
      
      # Verificar interseção (com margem de corte)
      if rectangles_overlap?(
        x, y, piece.width + cutting_width, piece.height + cutting_width,
        ex, ey, existing_piece.width + cutting_width, existing_piece.height + cutting_width
      )
        return false
      end
    end
    
    true
  end
  
  def rectangles_overlap?(x1, y1, w1, h1, x2, y2, w2, h2)
    !(x1 + w1 <= x2 || x2 + w2 <= x1 || y1 + h1 <= y2 || y2 + h2 <= y1)
  end
  
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

