# Representa uma peça que precisa ser cortada
class OptimizerPiece
  attr_accessor :id, :width, :height, :quantity, :label
  attr_reader :original_width, :original_height

  def initialize(id, width, height, quantity = 1, label = nil)
    @id = id
    @width = width
    @height = height
    @original_width = width
    @original_height = height
    @quantity = quantity
    @label = label || "Peça #{id}"
  end

  def area
    width * height
  end

  def rotate!
    @width, @height = @height, @width
  end

  def rotated?
    @width != @original_width
  end

  def to_s
    rotation = rotated? ? " (rotacionada)" : ""
    "#{label} [#{id}]: #{width}x#{height}mm#{rotation}"
  end
end

