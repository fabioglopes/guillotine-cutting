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
    
    # Try the new Max Waste Guillotine Optimizer first
    best_result = nil
    best_waste_area = 0
    
    @available_sheets.each_with_index do |template_sheet, sheet_idx|
      puts "\n--- Testando chapa #{template_sheet.label} ---"
      
      # Use Max Waste Guillotine Optimizer
      max_waste_optimizer = MaxWasteGuillotineOptimizer.new(
        template_sheet.width,
        template_sheet.height,
        @required_pieces,
        cutting_width
      )
      
      layout = max_waste_optimizer.optimize
      
      if layout && layout[:placed_pieces].any?
        # Convert to OptimizerSheet format
        sheet = OptimizerSheet.new(
          "#{template_sheet.id}-#{@used_sheets.length + 1}",
          template_sheet.width,
          template_sheet.height,
          "#{template_sheet.label} ##{@used_sheets.length + 1}"
        )
        
        layout[:placed_pieces].each do |placed|
          sheet.add_piece(placed[:piece], placed[:x], placed[:y], placed[:rotated])
        end
        
        # Calculate waste area
        waste_area = max_waste_optimizer.calculate_largest_waste_area(layout)
        utilization = max_waste_optimizer.calculate_utilization(layout)
        
        puts "  Maior sobra contígua: #{waste_area}mm²"
        puts "  Aproveitamento: #{utilization}%"
        
        if waste_area > best_waste_area
          best_result = sheet
          best_waste_area = waste_area
          puts "  ✅ Melhor resultado encontrado!"
        end
      end
    end
    
    if best_result
      best_result.cutting_width = cutting_width
      best_result.free_rectangles = [] # Will be calculated by calculate_offcuts
      @used_sheets << best_result
      @unplaced_pieces = []
      
      puts "\n=== Otimização concluída (Max Waste) ==="
      puts "Chapas utilizadas: #{@used_sheets.length}"
      puts "Peças cortadas: #{@required_pieces.length}"
      puts "Peças não colocadas: 0"
      puts "Maior sobra contígua: #{best_waste_area}mm²"
      
      return
    end
    
    # Fallback to original algorithm if Max Waste fails
    puts "\n--- Fallback para algoritmo original ---"
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
    
    puts "\n=== Otimização concluída (Fallback) ==="
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
       # Strategy: Group pieces by width to create uniform columns
       # This maximizes the chance of creating one large contiguous waste area
       groups = []
       pieces.each do |piece|
         # Group by width (with 10mm tolerance)
         group = groups.find { |g| (g[:width] - piece.width).abs <= 10 }
         
         if group
           group[:pieces] << piece
         else
           groups << { width: piece.width, pieces: [piece] }
         end
       end
       
       # Sort groups by width (narrowest first) to create columns from left to right
       # This leaves the largest waste area on the right side
       sorted_pieces = []
       groups.sort_by { |g| g[:width] }.each do |group|
         # Within each width group, sort by height (tallest first)
         sorted_pieces.concat(group[:pieces].sort_by(&:height).reverse)
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

