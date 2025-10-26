# Implementação do algoritmo Guillotine Bin Packing
# Ideal para cortes em marcenaria onde cortes são retos
class GuillotineBinPacker
  def initialize(width, height, cutting_width = 3)
    @width = width
    @height = height
    @cutting_width = cutting_width
    @free_rectangles = [{ x: 0, y: 0, width: width, height: height }]
  end

  def insert(piece, allow_rotation = true)
    best_rect = nil
    best_rect_index = nil
    rotated = false
    best_short_side_fit = Float::INFINITY

    # Adiciona espessura de corte às dimensões da peça
    piece_width = piece.width + @cutting_width
    piece_height = piece.height + @cutting_width

    # Tenta encontrar o melhor retângulo livre
    @free_rectangles.each_with_index do |rect, index|
      # Tenta sem rotação
      if fits?(piece_width, piece_height, rect)
        short_side_fit = [
          rect[:width] - piece_width,
          rect[:height] - piece_height
        ].min

        if short_side_fit < best_short_side_fit
          best_rect = rect
          best_rect_index = index
          best_short_side_fit = short_side_fit
          rotated = false
        end
      end

      # Tenta com rotação
      if allow_rotation && fits?(piece_height, piece_width, rect)
        short_side_fit = [
          rect[:width] - piece_height,
          rect[:height] - piece_width
        ].min

        if short_side_fit < best_short_side_fit
          best_rect = rect
          best_rect_index = index
          best_short_side_fit = short_side_fit
          rotated = true
        end
      end
    end

    return nil unless best_rect

    # Coloca a peça e divide o espaço restante
    result = {
      x: best_rect[:x],
      y: best_rect[:y],
      rotated: rotated
    }

    # Se rotacionou, troca as dimensões com corte também
    if rotated
      piece.rotate!
      piece_width, piece_height = piece_height, piece_width
    end

    split_free_rectangle(best_rect_index, piece_width, piece_height)

    result
  end

  private

  def fits?(width, height, rect)
    width <= rect[:width] && height <= rect[:height]
  end

  def split_free_rectangle(index, used_width, used_height)
    rect = @free_rectangles[index]
    
    # Remove o retângulo usado
    @free_rectangles.delete_at(index)

    # Cria novos retângulos livres (método Guillotine)
    # Divide horizontalmente ou verticalmente
    
    # Retângulo à direita
    if rect[:width] > used_width
      @free_rectangles << {
        x: rect[:x] + used_width,
        y: rect[:y],
        width: rect[:width] - used_width,
        height: used_height  # Altura apenas do espaço usado
      }
    end

    # Retângulo acima (ocupa toda a largura original)
    if rect[:height] > used_height
      @free_rectangles << {
        x: rect[:x],
        y: rect[:y] + used_height,
        width: rect[:width],  # Largura total do retângulo original
        height: rect[:height] - used_height
      }
    end

    # Remove retângulos que estão contidos em outros (otimização)
    prune_free_rectangles
  end

  def prune_free_rectangles
    i = 0
    while i < @free_rectangles.length
      j = i + 1
      while j < @free_rectangles.length
        if contains?(@free_rectangles[i], @free_rectangles[j])
          @free_rectangles.delete_at(j)
        elsif contains?(@free_rectangles[j], @free_rectangles[i])
          @free_rectangles.delete_at(i)
          i -= 1
          break
        else
          j += 1
        end
      end
      i += 1
    end
  end

  def contains?(rect1, rect2)
    rect1[:x] <= rect2[:x] &&
      rect1[:y] <= rect2[:y] &&
      rect1[:x] + rect1[:width] >= rect2[:x] + rect2[:width] &&
      rect1[:y] + rect1[:height] >= rect2[:y] + rect2[:height]
  end
end

