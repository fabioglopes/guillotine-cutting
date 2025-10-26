# Representa uma chapa disponível para corte
class OptimizerSheet
  attr_accessor :id, :width, :height, :label
  attr_reader :placed_pieces

  def initialize(id, width, height, label = nil)
    @id = id
    @width = width
    @height = height
    @label = label || "Chapa #{id}"
    @placed_pieces = []
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
end

