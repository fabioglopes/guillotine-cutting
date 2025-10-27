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
      
      sheet = Sheet.new(
        "#{template_sheet.id}-#{@used_sheets.length + 1}",
        template_sheet.width,
        template_sheet.height,
        "#{template_sheet.label} ##{@used_sheets.length + 1}"
      )
      
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
  
  def place_in_strips(sheet, pieces_to_place, groups, allow_rotation, cutting_width)
    placed_count = 0
    packer = GuillotineBinPacker.new(sheet.width, sheet.height, cutting_width)

    groups.each do |group|
      next if group[:pieces].empty?

      group[:pieces].each do |piece|
        next unless pieces_to_place.include?(piece)

        result = packer.insert(piece, allow_rotation)
        next unless result

        sheet.add_piece(piece, result[:x], result[:y], result[:rotated])
        pieces_to_place.delete(piece)
        placed_count += 1
      end
    end

    if placed_count > 0
      filler_candidates = pieces_to_place.sort_by { |p| -p.area }
      filler_candidates.each do |piece|
        result = packer.insert(piece, allow_rotation)
        next unless result

        sheet.add_piece(piece, result[:x], result[:y], result[:rotated])
        pieces_to_place.delete(piece)
        placed_count += 1
      end
    end

    sheet.free_rectangles = packer.free_rectangles.map { |rect| rect.dup }
    placed_count
  end
  
  def expand_pieces(pieces)
    expanded = []
    pieces.each do |piece|
      piece.quantity.times do |i|
        new_piece = Piece.new(
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
