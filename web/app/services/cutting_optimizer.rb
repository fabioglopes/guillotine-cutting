# Classes are loaded by Rails autoloader

# Classe principal para otimização de cortes
class CuttingOptimizer
  attr_reader :available_sheets, :required_pieces, :used_sheets, :unplaced_pieces

  def initialize(available_sheets, required_pieces)
    @available_sheets = available_sheets
    @required_pieces = expand_pieces(required_pieces)
    @used_sheets = []
    @unplaced_pieces = []
  end

  def optimize(allow_rotation: true, cutting_width: 3)
    puts "\n=== Iniciando otimização de cortes ==="
    puts "Total de peças a cortar: #{@required_pieces.length}"
    puts "Chapas disponíveis: #{@available_sheets.length}"
    puts "Espessura de corte (serra): #{cutting_width}mm"
    puts "Rotação permitida: #{allow_rotation ? 'Sim' : 'Não'}"
    
    # Ordena peças para maximizar sobras contíguas
    # Agrupa peças similares em dimensões para deixar grandes áreas livres
    pieces_to_place = smart_sort_pieces(@required_pieces)
    
    @available_sheets.each_with_index do |template_sheet, sheet_idx|
      break if pieces_to_place.empty?
      
      # Cria uma nova instância de chapa para uso
      sheet = OptimizerSheet.new(
        "#{template_sheet.id}-#{@used_sheets.length + 1}",
        template_sheet.width,
        template_sheet.height,
        "#{template_sheet.label} ##{@used_sheets.length + 1}"
      )
      
      # Usa algoritmo Guillotine para empacotar peças
      packer = GuillotineBinPacker.new(sheet.width, sheet.height, cutting_width)
      placed_in_sheet = []
      remaining_pieces = []
      
      pieces_to_place.each do |piece|
        result = packer.insert(piece, allow_rotation)
        
        if result
          sheet.add_piece(piece, result[:x], result[:y], result[:rotated])
          placed_in_sheet << piece
        else
          remaining_pieces << piece
        end
      end
      
      if placed_in_sheet.any?
        # Salvar retângulos livres para geração de sobras
        sheet.free_rectangles = packer.free_rectangles.dup
        sheet.cutting_width = cutting_width
        @used_sheets << sheet
        pieces_to_place = remaining_pieces
        puts "  Chapa #{sheet.label}: #{placed_in_sheet.length} peças colocadas (#{sheet.efficiency}% utilizada)"
      end
    end
    
    @unplaced_pieces = pieces_to_place
    
    puts "\n=== Otimização concluída ==="
    puts "Chapas utilizadas: #{@used_sheets.length}"
    puts "Peças cortadas: #{@required_pieces.length - @unplaced_pieces.length}"
    puts "Peças não colocadas: #{@unplaced_pieces.length}"
    
    if @unplaced_pieces.any?
      puts "\n⚠ ATENÇÃO: Algumas peças não puderam ser alocadas!"
      puts "Você precisará de mais chapas ou peças menores."
    end
  end

  private

  def smart_sort_pieces(pieces)
    # Agrupa peças por altura similar (tolerância de 10mm)
    # Isso ajuda a criar colunas uniformes e deixar grandes sobras contíguas
    groups = []
    pieces.each do |piece|
      # Usar a maior dimensão como referência para agrupamento
      ref_dim = [piece.width, piece.height].max
      
      # Procurar grupo existente com dimensão similar
      group = groups.find { |g| (g[:dimension] - ref_dim).abs <= 10 }
      
      if group
        group[:pieces] << piece
      else
        groups << { dimension: ref_dim, pieces: [piece] }
      end
    end
    
    # Ordenar grupos: primeiro os grupos com mais peças (para criar colunas uniformes)
    # Dentro de cada grupo, ordenar por área (maior primeiro)
    sorted_pieces = []
    groups.sort_by { |g| [-g[:pieces].length, -g[:dimension]] }.each do |group|
      sorted_pieces.concat(group[:pieces].sort_by(&:area).reverse)
    end
    
    sorted_pieces
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

