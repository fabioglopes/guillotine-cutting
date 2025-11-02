# Representa uma chapa disponível para corte
class OptimizerSheet
  attr_accessor :id, :width, :height, :label, :free_rectangles, :cutting_width, :snapshots
  attr_reader :placed_pieces

  def initialize(id, width, height, label = nil)
    @id = id
    @width = width
    @height = height
    @label = label || "Chapa #{id}"
    @placed_pieces = []
    @free_rectangles = []
    @cutting_width = 3
    @snapshots = []  # Novo: inicializar snapshots
  end

  def area
    width * height
  end

  def used_area
    @placed_pieces.sum { |pp| pp[:piece].area }
  end

  def efficiency
    return 0 if area == 0
    (used_area.to_f / area * 100).round(2)
  end

  def add_piece(piece, x, y, rotated = false)
    @placed_pieces << {
      piece: piece,
      x: x,
      y: y,
      rotated: rotated
    }
  end

  def to_s
    "#{label}: #{width}x#{height}mm (#{efficiency}% utilizada)"
  end

  # Calcula retângulos livres (sobras) após otimização
  # Retorna lista de hashes com: width, height, x, y e description
  # x,y estão em milímetros relativos ao canto superior esquerdo da chapa
  def calculate_offcuts(min_size = 300)
    offcuts = []
    
    return offcuts if @placed_pieces.empty?
    
    # Garantir que min_size é numérico
    min_size = min_size.to_f
    width_f = @width.to_f
    height_f = @height.to_f
    cutting_w = @cutting_width.to_f
    
    # Agrupar peças por posição X (colunas/faixas verticais)
    strips = @placed_pieces.group_by { |pp| pp[:x].to_f }.sort_by { |x, _| x }
    
    # Para cada faixa vertical, calcular sobras
    strips.each_with_index do |(strip_x, pieces_in_strip), index|
      # Determinar largura desta faixa
      # A largura vai até o início da próxima faixa ou até o fim da chapa
      if index < strips.length - 1
        next_strip_x = strips[index + 1][0].to_f
        strip_width = next_strip_x - strip_x - cutting_w
      else
        # Última faixa: calcular largura baseado nas peças
        max_piece_width = pieces_in_strip.map { |pp| pp[:piece].width.to_f }.max || 0
        strip_width = max_piece_width
      end
      
      # Calcular altura máxima usada nesta faixa
      max_y_in_strip = 0.0
      pieces_in_strip.each do |pp|
        piece_end_y = pp[:y].to_f + pp[:piece].height.to_f + cutting_w
        max_y_in_strip = [max_y_in_strip, piece_end_y].max
      end
      
      # Se há sobra no topo desta faixa
      if max_y_in_strip < height_f
        free_height = height_f - max_y_in_strip
        
        if strip_width >= min_size && free_height >= min_size
          offcuts << {
            width: strip_width.round,
            height: free_height.round,
            x: strip_x.round,
            y: max_y_in_strip.round,
            description: "sobra coluna #{index + 1}"
          }
        end
      end
    end
    
    # Calcular sobra à direita (se existir)
    max_x_used = 0.0
    if strips.any?
      # Encontrar o X máximo usado (fim da última coluna)
      last_strip_x = strips.last[0].to_f
      last_strip_pieces = strips.last[1]
      max_piece_width_last = last_strip_pieces.map { |pp| pp[:piece].width.to_f }.max || 0
      max_x_used = last_strip_x + max_piece_width_last + cutting_w
      
      if max_x_used < width_f
        right_width = width_f - max_x_used
        
        if right_width >= min_size && height_f >= min_size
          offcuts << {
            width: right_width.round,
            height: height_f.round,
            x: max_x_used.round,
            y: 0,
            description: "sobra direita"
          }
        end
      end
    end
    
    # Calcular sobra inferior combinada (se houver colunas com sobras pequenas)
    # Apenas se não capturamos as sobras individuais
    if strips.length > 1
      # Encontrar altura mínima de sobra entre todas as colunas
      min_free_height = Float::INFINITY
      
      strips.each do |strip_x, pieces_in_strip|
        max_y_in_strip = 0.0
        pieces_in_strip.each do |pp|
          piece_end_y = pp[:y].to_f + pp[:piece].height.to_f + cutting_w
          max_y_in_strip = [max_y_in_strip, piece_end_y].max
        end
        
        free_height = height_f - max_y_in_strip
        min_free_height = [min_free_height, free_height].min if free_height > 0
      end
      
      # Se há uma faixa horizontal livre no fundo (mesmo que pequena)
      if min_free_height > 50 && min_free_height < min_size && max_x_used >= min_size
        offcuts << {
          width: max_x_used.round,
          height: min_free_height.round,
          x: 0,
          y: (height_f - min_free_height).round,
          description: "sobra inferior"
        }
      end
    end
    
    # Remover duplicatas (sobras muito similares - diferença < 10mm)
    offcuts.uniq! do |o|
      [o[:width] / 10, o[:height] / 10].sort
    end
    
    offcuts
  end
end

