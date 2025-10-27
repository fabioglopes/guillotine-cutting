# Representa uma chapa disponível para corte
class OptimizerSheet
  attr_accessor :id, :width, :height, :label, :free_rectangles, :cutting_width
  attr_reader :placed_pieces

  def initialize(id, width, height, label = nil)
    @id = id
    @width = width
    @height = height
    @label = label || "Chapa #{id}"
    @placed_pieces = []
    @free_rectangles = []
    @cutting_width = 3
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
  # Retorna lista de hashes com: width, height, x, y, area_mm2 e description
  # x,y estão em milímetros relativos ao canto superior esquerdo da chapa
  def calculate_offcuts(min_size = 300)
    return [] if @placed_pieces.empty?

    min_size = min_size.to_f

    if free_rectangles_available?
      offcuts = offcuts_from_free_rectangles(min_size)
      return offcuts if offcuts.any?
    end

    legacy_offcuts(min_size)
  end

  private

  def free_rectangles_available?
    @free_rectangles && @free_rectangles.any?
  end

  def offcuts_from_free_rectangles(min_size)
    rectangles = @free_rectangles.filter_map do |rect|
      width = rect[:width].to_f
      height = rect[:height].to_f
      next if width <= 0 || height <= 0

      {
        x: rect[:x].to_f,
        y: rect[:y].to_f,
        width: width,
        height: height
      }
    end

    return [] if rectangles.empty?

    tolerance = [(cutting_width || 3).to_f, 1.0].max + 0.1
    visited = Array.new(rectangles.length, false)
    groups = []

    rectangles.each_index do |index|
      next if visited[index]

      stack = [index]
      visited[index] = true
      group = []

      until stack.empty?
        current_idx = stack.pop
        current_rect = rectangles[current_idx]
        group << current_rect

        rectangles.each_with_index do |other_rect, other_idx|
          next if visited[other_idx]
          if rectangles_touch?(current_rect, other_rect, tolerance)
            visited[other_idx] = true
            stack << other_idx
          end
        end
      end

      groups << group
    end

    groups.each_with_index.map do |group, idx|
      total_area = group.sum { |r| r[:width] * r[:height] }
      next if total_area <= 0

      min_x = group.map { |r| r[:x] }.min
      min_y = group.map { |r| r[:y] }.min
      max_x = group.map { |r| r[:x] + r[:width] }.max
      max_y = group.map { |r| r[:y] + r[:height] }.max

      width = max_x - min_x
      height = max_y - min_y

      next if width < min_size || height < min_size

      {
        width: width.round,
        height: height.round,
        x: min_x.round,
        y: min_y.round,
        area_mm2: total_area.round,
        description: group.length > 1 ? "sobra contígua (#{group.length} regiões)" : "sobra contígua"
      }
    end.compact
  end

  def rectangles_touch?(a, b, tolerance)
    ax1 = a[:x]
    ay1 = a[:y]
    ax2 = ax1 + a[:width]
    ay2 = ay1 + a[:height]

    bx1 = b[:x]
    by1 = b[:y]
    bx2 = bx1 + b[:width]
    by2 = by1 + b[:height]

    horizontal_overlap = [ay2, by2].min - [ay1, by1].max
    vertical_overlap = [ax2, bx2].min - [ax1, bx1].max

    share_vertical_edge = ((ax2 - bx1).abs <= tolerance || (bx2 - ax1).abs <= tolerance) && horizontal_overlap > 0
    share_horizontal_edge = ((ay2 - by1).abs <= tolerance || (by2 - ay1).abs <= tolerance) && vertical_overlap > 0
    overlap = horizontal_overlap > 0 && vertical_overlap > 0

    share_vertical_edge || share_horizontal_edge || overlap
  end

  def legacy_offcuts(min_size)
    offcuts = []

    width_f = @width.to_f
    height_f = @height.to_f
    cutting_w = @cutting_width.to_f

    strips = @placed_pieces.group_by { |pp| pp[:x].to_f }.sort_by { |x, _| x }

    strips.each_with_index do |(strip_x, pieces_in_strip), index|
      strip_width =
        if index < strips.length - 1
          next_strip_x = strips[index + 1][0].to_f
          next_strip_x - strip_x - cutting_w
        else
          pieces_in_strip.map { |pp| pp[:piece].width.to_f }.max || 0
        end

      max_y_in_strip = pieces_in_strip.reduce(0.0) do |acc, pp|
        piece_end_y = pp[:y].to_f + pp[:piece].height.to_f + cutting_w
        [acc, piece_end_y].max
      end

      if max_y_in_strip < height_f
        free_height = height_f - max_y_in_strip

        if strip_width >= min_size && free_height >= min_size
          offcuts << {
            width: strip_width.round,
            height: free_height.round,
            x: strip_x.round,
            y: max_y_in_strip.round,
            area_mm2: (strip_width * free_height).round,
            description: "sobra coluna #{index + 1}"
          }
        end
      end
    end

    max_x_used = 0.0

    if strips.any?
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
            area_mm2: (right_width * height_f).round,
            description: "sobra direita"
          }
        end
      end
    end

    if strips.length > 1
      min_free_height = Float::INFINITY

      strips.each do |_strip_x, pieces_in_strip|
        max_y_in_strip = pieces_in_strip.reduce(0.0) do |acc, pp|
          piece_end_y = pp[:y].to_f + pp[:piece].height.to_f + cutting_w
          [acc, piece_end_y].max
        end

        free_height = height_f - max_y_in_strip
        min_free_height = [min_free_height, free_height].min if free_height > 0
      end

      if min_free_height > 50 && min_free_height < min_size && max_x_used >= min_size
        offcuts << {
          width: max_x_used.round,
          height: min_free_height.round,
          x: 0,
          y: (height_f - min_free_height).round,
          area_mm2: (max_x_used * min_free_height).round,
          description: "sobra inferior"
        }
      end
    end

    offcuts.uniq! do |o|
      [o[:width] / 10, o[:height] / 10].sort
    end

    offcuts
  end
end
