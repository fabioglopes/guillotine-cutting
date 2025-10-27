# Implementação do algoritmo Guillotine Bin Packing
# Ideal para cortes em marcenaria onde cortes são retos
class GuillotineBinPacker
  attr_reader :free_rectangles, :cutting_width

  def initialize(width, height, cutting_width = 3)
    @width = width
    @height = height
    @cutting_width = cutting_width
    @free_rectangles = [{ x: 0, y: 0, width: width, height: height }]
  end

  def insert(piece, allow_rotation = true)
    best_candidate = nil
    orig_piece_width = piece.width
    orig_piece_height = piece.height

    width_with_kerf = orig_piece_width + @cutting_width
    height_with_kerf = orig_piece_height + @cutting_width

    @free_rectangles.each_with_index do |rect, index|
      if fits?(width_with_kerf, height_with_kerf, rect)
        candidate = build_candidate(
          rect: rect,
          index: index,
          used_width: width_with_kerf,
          used_height: height_with_kerf,
          rotated: false,
          short_side_fit: short_side_fit(rect, width_with_kerf, height_with_kerf)
        )
        best_candidate = candidate if better_candidate?(candidate, best_candidate)
      end

      next unless allow_rotation

      rotated_width_with_kerf = orig_piece_height + @cutting_width
      rotated_height_with_kerf = orig_piece_width + @cutting_width

      if fits?(rotated_width_with_kerf, rotated_height_with_kerf, rect)
        candidate = build_candidate(
          rect: rect,
          index: index,
          used_width: rotated_width_with_kerf,
          used_height: rotated_height_with_kerf,
          rotated: true,
          short_side_fit: short_side_fit(rect, rotated_width_with_kerf, rotated_height_with_kerf)
        )
        best_candidate = candidate if better_candidate?(candidate, best_candidate)
      end
    end

    return nil unless best_candidate

    if best_candidate[:rotated]
      piece.rotate!
    end

    split_free_rectangle(best_candidate[:index], best_candidate[:used_width], best_candidate[:used_height])

    {
      x: best_candidate[:rect][:x],
      y: best_candidate[:rect][:y],
      rotated: best_candidate[:rotated]
    }
  end

  private

  def rectangle_area(rect)
    rect[:width] * rect[:height]
  end

  def fits?(width, height, rect)
    width <= rect[:width] && height <= rect[:height]
  end

  def short_side_fit(rect, width, height)
    [
      rect[:width] - width,
      rect[:height] - height
    ].min
  end

  def build_candidate(rect:, index:, used_width:, used_height:, rotated:, short_side_fit:)
    preview = preview_split(rect, used_width, used_height)
    return nil unless preview

    {
      rect: rect,
      index: index,
      rotated: rotated,
      used_width: used_width,
      used_height: used_height,
      short_side_fit: short_side_fit,
      largest_offcut_area: global_largest_area(index, preview[:rectangles]),
      rect_area: rectangle_area(rect)
    }
  end

  def better_candidate?(candidate, current_best)
    return false unless candidate
    return true unless current_best

    # Primary: Maximize the largest contiguous waste area
    cmp = candidate[:largest_offcut_area] <=> current_best[:largest_offcut_area]
    return cmp == 1 if cmp != 0

    # Secondary: Strongly prefer placements that create ONE large waste area vs many small ones
    candidate_waste_count = count_significant_waste_areas(candidate)
    best_waste_count = count_significant_waste_areas(current_best)
    
    # If one creates significantly fewer waste areas, prefer it
    if (candidate_waste_count - best_waste_count).abs >= 2
      return candidate_waste_count < best_waste_count
    end

    # Tertiary: Prefer placements that leave more total waste area
    candidate_total_waste = calculate_total_waste_area(candidate)
    best_total_waste = calculate_total_waste_area(current_best)
    cmp = candidate_total_waste <=> best_total_waste
    return cmp == 1 if cmp != 0

    # Final tiebreaker: better short side fit
    candidate[:short_side_fit] < current_best[:short_side_fit]
  end

  def split_free_rectangle(index, used_width, used_height)
    rect = @free_rectangles.delete_at(index)
    return unless rect

    chosen_split = preview_split(rect, used_width, used_height)[:rectangles]
    chosen_split.each do |new_rect|
      next if new_rect[:width] <= 0 || new_rect[:height] <= 0
      @free_rectangles << new_rect
    end

     # Remove retângulos que estão contidos em outros (otimização)
     prune_free_rectangles
     # Ordena para tentar preencher primeiro as menores sobras, preservando as grandes
     # This helps maintain large contiguous waste areas
     @free_rectangles.sort_by! { |rect_free| rectangle_area(rect_free) }
  end

  def preview_split(rect, used_width, used_height)
    options = split_options(rect, used_width, used_height)
    chosen_split = choose_split(rect, used_width, used_height, options[:horizontal], options[:vertical])
    {
      rectangles: chosen_split,
      largest_area: chosen_split.map { |r| rectangle_area(r) }.max || 0
    }
  end

  def split_options(rect, used_width, used_height)
    horizontal_split = []
    vertical_split = []

    if rect[:height] > used_height
      horizontal_split << {
        x: rect[:x],
        y: rect[:y] + used_height,
        width: rect[:width],
        height: rect[:height] - used_height
      }
    end

    if rect[:width] > used_width
      horizontal_split << {
        x: rect[:x] + used_width,
        y: rect[:y],
        width: rect[:width] - used_width,
        height: used_height
      }
    end

    if rect[:width] > used_width
      vertical_split << {
        x: rect[:x] + used_width,
        y: rect[:y],
        width: rect[:width] - used_width,
        height: rect[:height]
      }
    end

    if rect[:height] > used_height
      vertical_split << {
        x: rect[:x],
        y: rect[:y] + used_height,
        width: used_width,
        height: rect[:height] - used_height
      }
    end

    { horizontal: horizontal_split, vertical: vertical_split }
  end

  def global_largest_area(replaced_index, new_rectangles)
    max_area = new_rectangles.map { |r| rectangle_area(r) }.max || 0

    @free_rectangles.each_with_index do |rect, idx|
      next if idx == replaced_index
      area = rectangle_area(rect)
      max_area = area if area > max_area
    end

    max_area
  end

  def choose_split(rect, used_width, used_height, horizontal_split, vertical_split)
    # Quando um dos splits resulta em nenhuma sobra (chapa preenchida exatamente)
    return vertical_split if horizontal_split.empty?
    return horizontal_split if vertical_split.empty?

    # Calculate areas of waste regions for each split option
    horizontal_max_area = horizontal_split.map { |r| rectangle_area(r) }.max || 0
    vertical_max_area = vertical_split.map { |r| rectangle_area(r) }.max || 0
    
    # Calculate total waste area for each option
    horizontal_total = horizontal_split.sum { |r| rectangle_area(r) }
    vertical_total = vertical_split.sum { |r| rectangle_area(r) }
    
    # Strongly prefer splits that create ONE large area vs multiple smaller ones
    if horizontal_split.length == 1 && vertical_split.length > 1
      return horizontal_split
    elsif vertical_split.length == 1 && horizontal_split.length > 1
      return vertical_split
    end
    
    # If both create same number of regions, prefer the one with larger max area
    if horizontal_max_area > vertical_max_area
      horizontal_split
    elsif vertical_max_area > horizontal_max_area
      vertical_split
    else
      # Tie: prefer split that creates fewer waste regions (more contiguous)
      horizontal_split.length <= vertical_split.length ? horizontal_split : vertical_split
    end
  end

  def count_significant_waste_areas(candidate)
    # Count waste areas larger than 5% of the original sheet area (more aggressive)
    min_significant_area = (@width * @height) * 0.05
    
    preview = preview_split(candidate[:rect], candidate[:used_width], candidate[:used_height])
    significant_count = preview[:rectangles].count { |r| rectangle_area(r) >= min_significant_area }
    
    # Also count existing significant areas
    @free_rectangles.each do |rect|
      significant_count += 1 if rectangle_area(rect) >= min_significant_area
    end
    
    significant_count
  end

  def calculate_total_waste_area(candidate)
    preview = preview_split(candidate[:rect], candidate[:used_width], candidate[:used_height])
    total_area = preview[:rectangles].sum { |r| rectangle_area(r) }
    
    # Add existing waste areas
    @free_rectangles.each do |rect|
      total_area += rectangle_area(rect)
    end
    
    total_area
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
