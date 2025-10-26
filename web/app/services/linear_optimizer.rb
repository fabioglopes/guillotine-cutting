# Linear Cut Optimizer for 1D materials (tubes, bars, profiles)
# Otimizador de Cortes Lineares para materiais 1D (tubos, barras, perfis)

class LinearPiece
  attr_accessor :id, :length, :quantity, :label
  attr_reader :original_length

  def initialize(id, length, quantity = 1, label = nil)
    @id = id
    @length = length
    @original_length = length
    @quantity = quantity
    @label = label || "Peça #{id}"
  end

  def to_s
    "#{label} [#{id}]: #{length}mm"
  end
end

class LinearBar
  attr_accessor :id, :length, :label, :cuts, :used_length, :waste

  def initialize(id, length, label = nil)
    @id = id
    @length = length
    @label = label || "Barra #{id}"
    @cuts = []
    @used_length = 0
    @waste = length
  end

  def can_fit?(piece_length, cutting_width)
    remaining = @waste - cutting_width
    remaining >= piece_length
  end

  def add_cut(piece, cutting_width)
    # Add cutting width before the piece (except for first cut)
    actual_width = @cuts.empty? ? 0 : cutting_width
    
    if can_fit?(piece.length, actual_width)
      position = @used_length + actual_width
      
      @cuts << {
        piece: piece,
        position: position,
        length: piece.length
      }
      
      @used_length = position + piece.length
      @waste = @length - @used_length
      return true
    end
    
    false
  end

  def efficiency
    return 0 if @length == 0
    ((@used_length.to_f / @length) * 100).round(2)
  end

  def to_s
    "#{label}: #{cuts.length} cortes, #{efficiency}% utilizada, #{waste}mm desperdício"
  end
end

class LinearOptimizer
  attr_reader :available_bars, :required_pieces, :used_bars, :unallocated_pieces

  def initialize(available_bars, required_pieces)
    @available_bars = available_bars
    @required_pieces = required_pieces
    @used_bars = []
    @unallocated_pieces = []
  end

  def optimize(cutting_width: 3)
    puts "\n=== Iniciando otimização de cortes lineares ==="
    puts "Barras disponíveis: #{@available_bars.length}"
    puts "Total de peças a cortar: #{total_pieces}"
    puts "Espessura de corte: #{cutting_width}mm"

    # Expand pieces by quantity and sort by length (largest first)
    expanded_pieces = []
    @required_pieces.each do |piece|
      piece.quantity.times do |i|
        piece_id = "#{piece.id}.#{i + 1}"
        expanded_pieces << LinearPiece.new(piece_id, piece.length, 1, piece.label)
      end
    end

    # Sort pieces by length (descending) - First Fit Decreasing (FFD) algorithm
    expanded_pieces.sort_by! { |p| -p.length }

    # Try to fit pieces into bars using First Fit Decreasing
    bar_index = 0
    
    expanded_pieces.each do |piece|
      placed = false

      # Try existing used bars first
      @used_bars.each do |bar|
        if bar.add_cut(piece, cutting_width)
          placed = true
          break
        end
      end

      # If not placed, try to use a new bar
      unless placed
        while bar_index < @available_bars.length && !placed
          new_bar = @available_bars[bar_index]
          bar_index += 1
          
          if new_bar.add_cut(piece, cutting_width)
            @used_bars << new_bar
            placed = true
          end
        end
      end

      # If still not placed, add to unallocated
      unless placed
        @unallocated_pieces << piece
      end
    end

    # Show progress
    @used_bars.each do |bar|
      puts "  #{bar}"
    end

    puts "\n=== Otimização concluída ==="
    puts "Barras utilizadas: #{@used_bars.length}"
    puts "Peças cortadas: #{total_pieces - @unallocated_pieces.length}"
    puts "Peças não colocadas: #{@unallocated_pieces.length}"
    
    if @unallocated_pieces.any?
      puts "\n⚠️  PEÇAS NÃO ALOCADAS:"
      @unallocated_pieces.each do |piece|
        puts "  • #{piece}"
      end
    end
  end

  def total_pieces
    @required_pieces.sum(&:quantity)
  end

  def total_efficiency
    return 0 if @used_bars.empty?
    
    total_length = @used_bars.sum(&:length)
    total_used = @used_bars.sum(&:used_length)
    
    ((total_used.to_f / total_length) * 100).round(2)
  end

  def total_waste
    @used_bars.sum(&:waste)
  end
end

