# Two-Stage Guillotine Optimizer designed to maximize the largest contiguous waste area
# Based on research: Two-stage guillotine cutting with multi-pass optimization
class MaxWasteGuillotineOptimizer
  attr_reader :sheet_width, :sheet_height, :cutting_width, :pieces

  def initialize(sheet_width, sheet_height, pieces, cutting_width = 3)
    @sheet_width = sheet_width
    @sheet_height = sheet_height
    @pieces = pieces
    @cutting_width = cutting_width
  end

  def optimize
    puts "\n=== Max Waste Guillotine Optimization ==="
    puts "Sheet: #{@sheet_width}x#{@sheet_height}mm"
    puts "Pieces: #{@pieces.length}"
    puts "Cutting width: #{@cutting_width}mm"
    
    best_layout = nil
    best_waste_area = 0
    best_utilization = 0
    
    # Multi-pass optimization: try different strategies
    strategies = [
      :maximize_right_waste,    # NEW: Pack pieces on left to create large right waste area
      :horizontal_strips_first,  # Create horizontal strips, then vertical cuts
      :vertical_strips_first,    # Create vertical strips, then horizontal cuts
      :corner_packing,          # Pack pieces in one corner to leave large waste area
      :edge_packing              # Pack pieces along edges to leave center waste area
    ]
    
    strategies.each_with_index do |strategy, pass|
      puts "\n--- Pass #{pass + 1}: #{strategy.to_s.humanize} ---"
      
      layout = case strategy
      when :maximize_right_waste
        optimize_maximize_right_waste
      when :horizontal_strips_first
        optimize_horizontal_strips
      when :vertical_strips_first
        optimize_vertical_strips
      when :corner_packing
        optimize_corner_packing
      when :edge_packing
        optimize_edge_packing
      end
      
      next unless layout
      
      waste_area = calculate_largest_waste_area(layout)
      utilization = calculate_utilization(layout)
      
      puts "  Largest waste area: #{waste_area}mm²"
      puts "  Utilization: #{utilization.round(2)}%"
      
      # Choose layout with largest contiguous waste area
      if waste_area > best_waste_area
        best_layout = layout
        best_waste_area = waste_area
        best_utilization = utilization
        puts "  ✅ New best layout!"
      end
    end
    
    puts "\n=== Final Result ==="
    puts "Best strategy: #{best_layout[:strategy]}"
    puts "Largest waste area: #{best_waste_area}mm²"
    puts "Utilization: #{best_utilization.round(2)}%"
    
    best_layout
  end

  def calculate_largest_waste_area(layout)
    return 0 unless layout && layout[:placed_pieces]
    
    # Create a grid to track used areas
    grid = Array.new(@sheet_height) { Array.new(@sheet_width, false) }
    
    # Mark used areas
    layout[:placed_pieces].each do |placed|
      piece = placed[:piece]
      x = placed[:x].to_i
      y = placed[:y].to_i
      width = piece.width.to_i
      height = piece.height.to_i
      
      (y...[y + height, @sheet_height].min).each do |row|
        (x...[x + width, @sheet_width].min).each do |col|
          grid[row][col] = true
        end
      end
    end
    
    # Find largest contiguous free area using flood fill
    max_area = 0
    visited = Array.new(@sheet_height) { Array.new(@sheet_width, false) }
    
    (0...@sheet_height).each do |y|
      (0...@sheet_width).each do |x|
        unless visited[y][x] || grid[y][x]
          area = flood_fill(grid, visited, x, y)
          max_area = [max_area, area].max
        end
      end
    end
    
    max_area
  end

  def calculate_utilization(layout)
    return 0 unless layout && layout[:placed_pieces]
    
    used_area = layout[:placed_pieces].sum { |placed| placed[:piece].area }
    total_area = @sheet_width * @sheet_height
    
    (used_area.to_f / total_area * 100).round(2)
  end

  private

  def optimize_maximize_right_waste
    # Strategy: Pack pieces on the left side to create the largest possible right waste area
    # This is specifically designed to create the "black box" waste area (~1.1m²)
    
    sorted_pieces = @pieces.sort_by { |p| -p.height } # Tallest pieces first
    layout = { strategy: :maximize_right_waste, placed_pieces: [] }
    
    # Calculate total width of all pieces
    total_pieces_width = sorted_pieces.sum { |p| p.width + @cutting_width } - @cutting_width
    
    puts "  Total pieces width: #{total_pieces_width}mm, Sheet width: #{@sheet_width}mm"
    
    # Try to create the most compact arrangement possible
    # Goal: Use as little width as possible to maximize right waste area
    
    best_layout = nil
    min_width_used = Float::INFINITY
    
    # Strategy 1: Try to fit all pieces in one row (if possible)
    if total_pieces_width <= @sheet_width
      puts "  Trying single row arrangement..."
      single_row_layout = create_single_row_layout(sorted_pieces)
      if single_row_layout
        width_used = single_row_layout[:placed_pieces].map { |p| p[:x] + p[:piece].width }.max
        if width_used < min_width_used
          min_width_used = width_used
          best_layout = single_row_layout
          puts "  Single row uses #{width_used}mm width"
        end
      end
    end
    
    # Strategy 2: Try compact 2-row arrangements
    puts "  Trying 2-row arrangements..."
    (1..sorted_pieces.length-1).each do |split_point|
      row1_pieces = sorted_pieces[0...split_point]
      row2_pieces = sorted_pieces[split_point..-1]
      
      row1_width = row1_pieces.sum { |p| p.width + @cutting_width } - @cutting_width
      row2_width = row2_pieces.sum { |p| p.width + @cutting_width } - @cutting_width
      
      if row1_width <= @sheet_width && row2_width <= @sheet_width
        two_row_layout = create_two_row_layout(row1_pieces, row2_pieces)
        if two_row_layout
          width_used = [row1_width, row2_width].max
          if width_used < min_width_used
            min_width_used = width_used
            best_layout = two_row_layout
            puts "  2-row split at #{split_point}: uses #{width_used}mm width"
          end
        end
      end
    end
    
    # Strategy 3: Try compact 3-row arrangements
    puts "  Trying 3-row arrangements..."
    (1..sorted_pieces.length-2).each do |split1|
      (split1+1..sorted_pieces.length-1).each do |split2|
        row1_pieces = sorted_pieces[0...split1]
        row2_pieces = sorted_pieces[split1...split2]
        row3_pieces = sorted_pieces[split2..-1]
        
        row1_width = row1_pieces.sum { |p| p.width + @cutting_width } - @cutting_width
        row2_width = row2_pieces.sum { |p| p.width + @cutting_width } - @cutting_width
        row3_width = row3_pieces.sum { |p| p.width + @cutting_width } - @cutting_width
        
        if row1_width <= @sheet_width && row2_width <= @sheet_width && row3_width <= @sheet_width
          three_row_layout = create_three_row_layout(row1_pieces, row2_pieces, row3_pieces)
          if three_row_layout
            width_used = [row1_width, row2_width, row3_width].max
            if width_used < min_width_used
              min_width_used = width_used
              best_layout = three_row_layout
              puts "  3-row split at #{split1},#{split2}: uses #{width_used}mm width"
            end
          end
        end
      end
    end
    
    # Use the best layout found
    if best_layout
      puts "  Best layout uses #{min_width_used}mm width, leaving #{@sheet_width - min_width_used}mm for waste area"
      return best_layout
    end
    
    # Fallback: use simple corner packing
    puts "  Using fallback corner packing..."
    return create_fallback_layout(sorted_pieces)
  end

  def create_single_row_layout(pieces)
    layout = { strategy: :maximize_right_waste, placed_pieces: [] }
    current_x = 0
    current_y = 0
    
    pieces.each do |piece|
      layout[:placed_pieces] << {
        piece: piece,
        x: current_x,
        y: current_y,
        rotated: false
      }
      current_x += piece.width + @cutting_width
    end
    
    layout
  end

  def create_two_row_layout(row1_pieces, row2_pieces)
    layout = { strategy: :maximize_right_waste, placed_pieces: [] }
    
    # Place first row
    current_x = 0
    current_y = 0
    max_height_row1 = 0
    
    row1_pieces.each do |piece|
      layout[:placed_pieces] << {
        piece: piece,
        x: current_x,
        y: current_y,
        rotated: false
      }
      current_x += piece.width + @cutting_width
      max_height_row1 = [max_height_row1, piece.height + @cutting_width].max
    end
    
    # Place second row
    current_x = 0
    current_y += max_height_row1
    
    row2_pieces.each do |piece|
      layout[:placed_pieces] << {
        piece: piece,
        x: current_x,
        y: current_y,
        rotated: false
      }
      current_x += piece.width + @cutting_width
    end
    
    layout
  end

  def create_three_row_layout(row1_pieces, row2_pieces, row3_pieces)
    layout = { strategy: :maximize_right_waste, placed_pieces: [] }
    
    # Place first row
    current_x = 0
    current_y = 0
    max_height_row1 = 0
    
    row1_pieces.each do |piece|
      layout[:placed_pieces] << {
        piece: piece,
        x: current_x,
        y: current_y,
        rotated: false
      }
      current_x += piece.width + @cutting_width
      max_height_row1 = [max_height_row1, piece.height + @cutting_width].max
    end
    
    # Place second row
    current_x = 0
    current_y += max_height_row1
    max_height_row2 = 0
    
    row2_pieces.each do |piece|
      layout[:placed_pieces] << {
        piece: piece,
        x: current_x,
        y: current_y,
        rotated: false
      }
      current_x += piece.width + @cutting_width
      max_height_row2 = [max_height_row2, piece.height + @cutting_width].max
    end
    
    # Place third row
    current_x = 0
    current_y += max_height_row2
    
    row3_pieces.each do |piece|
      layout[:placed_pieces] << {
        piece: piece,
        x: current_x,
        y: current_y,
        rotated: false
      }
      current_x += piece.width + @cutting_width
    end
    
    layout
  end

  def create_fallback_layout(pieces)
    layout = { strategy: :maximize_right_waste, placed_pieces: [] }
    current_x = 0
    current_y = 0
    max_height_in_row = 0
    
    pieces.each do |piece|
      if current_x + piece.width <= @sheet_width && current_y + piece.height <= @sheet_height
        layout[:placed_pieces] << {
          piece: piece,
          x: current_x,
          y: current_y,
          rotated: false
        }
        current_x += piece.width + @cutting_width
        max_height_in_row = [max_height_in_row, piece.height + @cutting_width].max
      else
        current_x = 0
        current_y += max_height_in_row
        max_height_in_row = piece.height + @cutting_width
        
        if current_y + piece.height <= @sheet_height
          layout[:placed_pieces] << {
            piece: piece,
            x: current_x,
            y: current_y,
            rotated: false
          }
          current_x += piece.width + @cutting_width
        end
      end
    end
    
    layout
  end

  def optimize_horizontal_strips
    # Strategy: Create horizontal strips, then make vertical cuts within each strip
    # This tends to leave one large vertical waste area
    
    sorted_pieces = @pieces.sort_by { |p| -p.height } # Tallest pieces first
    layout = { strategy: :horizontal_strips_first, strips: [], placed_pieces: [] }
    
    # Simple row-by-row placement
    current_y = 0
    current_x = 0
    max_height_in_row = 0
    
    sorted_pieces.each do |piece|
      # Check if piece fits in current row
      if current_x + piece.width <= @sheet_width && current_y + piece.height <= @sheet_height
        layout[:placed_pieces] << {
          piece: piece,
          x: current_x,
          y: current_y,
          rotated: false
        }
        current_x += piece.width + @cutting_width
        max_height_in_row = [max_height_in_row, piece.height + @cutting_width].max
      else
        # Move to next row
        current_x = 0
        current_y += max_height_in_row
        max_height_in_row = piece.height + @cutting_width
        
        if current_y + piece.height <= @sheet_height
          layout[:placed_pieces] << {
            piece: piece,
            x: current_x,
            y: current_y,
            rotated: false
          }
          current_x += piece.width + @cutting_width
        end
      end
    end
    
    layout
  end

  def place_row_pieces(pieces, y, layout)
    return if pieces.empty?
    
    current_x = 0
    pieces.each do |piece|
      if current_x + piece.width <= @sheet_width
        layout[:placed_pieces] << {
          piece: piece,
          x: current_x,
          y: y,
          rotated: false
        }
        current_x += piece.width + @cutting_width
      end
    end
  end

  def optimize_vertical_strips
    # Strategy: Create vertical strips, then make horizontal cuts within each strip
    # This tends to leave one large horizontal waste area
    
    sorted_pieces = @pieces.sort_by { |p| -p.width } # Widest pieces first
    layout = { strategy: :vertical_strips_first, strips: [], placed_pieces: [] }
    
    # Simple column-by-column placement
    current_x = 0
    current_y = 0
    max_width_in_col = 0
    
    sorted_pieces.each do |piece|
      # Check if piece fits in current column
      if current_y + piece.height <= @sheet_height && current_x + piece.width <= @sheet_width
        layout[:placed_pieces] << {
          piece: piece,
          x: current_x,
          y: current_y,
          rotated: false
        }
        current_y += piece.height + @cutting_width
        max_width_in_col = [max_width_in_col, piece.width + @cutting_width].max
      else
        # Move to next column
        current_y = 0
        current_x += max_width_in_col
        max_width_in_col = piece.width + @cutting_width
        
        if current_x + piece.width <= @sheet_width
          layout[:placed_pieces] << {
            piece: piece,
            x: current_x,
            y: current_y,
            rotated: false
          }
          current_y += piece.height + @cutting_width
        end
      end
    end
    
    layout
  end

  def place_col_pieces(pieces, x, layout)
    return if pieces.empty?
    
    current_y = 0
    pieces.each do |piece|
      if current_y + piece.height <= @sheet_height
        layout[:placed_pieces] << {
          piece: piece,
          x: x,
          y: current_y,
          rotated: false
        }
        current_y += piece.height + @cutting_width
      end
    end
  end

  def optimize_corner_packing
    # Strategy: Pack pieces in one corner (top-left) to leave large waste area
    # This maximizes the waste area in the opposite corner
    
    sorted_pieces = @pieces.sort_by { |p| [p.width, p.height] } # Smallest first for better packing
    layout = { strategy: :corner_packing, placed_pieces: [] }
    
    # Use bottom-left fill algorithm
    current_x = 0
    current_y = 0
    max_height_in_row = 0
    
    sorted_pieces.each do |piece|
      # Try to place in current row
      if current_x + piece.width <= @sheet_width && current_y + piece.height <= @sheet_height
        layout[:placed_pieces] << {
          piece: piece,
          x: current_x,
          y: current_y,
          rotated: false
        }
        current_x += piece.width + @cutting_width
        max_height_in_row = [max_height_in_row, piece.height + @cutting_width].max
      else
        # Move to next row
        current_x = 0
        current_y += max_height_in_row
        max_height_in_row = piece.height + @cutting_width
        
        if current_y + piece.height <= @sheet_height
          layout[:placed_pieces] << {
            piece: piece,
            x: current_x,
            y: current_y,
            rotated: false
          }
          current_x += piece.width + @cutting_width
        end
      end
    end
    
    layout
  end

  def optimize_edge_packing
    # Strategy: Pack pieces along edges to leave center waste area
    # This creates a large rectangular waste area in the center
    
    sorted_pieces = @pieces.sort_by { |p| -p.area } # Largest pieces first
    layout = { strategy: :edge_packing, placed_pieces: [] }
    
    # Simple corner packing as fallback
    current_x = 0
    current_y = 0
    max_height_in_row = 0
    
    sorted_pieces.each do |piece|
      # Try to place in current row
      if current_x + piece.width <= @sheet_width && current_y + piece.height <= @sheet_height
        layout[:placed_pieces] << {
          piece: piece,
          x: current_x,
          y: current_y,
          rotated: false
        }
        current_x += piece.width + @cutting_width
        max_height_in_row = [max_height_in_row, piece.height + @cutting_width].max
      else
        # Move to next row
        current_x = 0
        current_y += max_height_in_row
        max_height_in_row = piece.height + @cutting_width
        
        if current_y + piece.height <= @sheet_height
          layout[:placed_pieces] << {
            piece: piece,
            x: current_x,
            y: current_y,
            rotated: false
          }
          current_x += piece.width + @cutting_width
        end
      end
    end
    
    layout
  end

  def flood_fill(grid, visited, start_x, start_y)
    return 0 if start_x < 0 || start_x >= @sheet_width || 
               start_y < 0 || start_y >= @sheet_height ||
               visited[start_y][start_x] || grid[start_y][start_x]
    
    stack = [[start_x, start_y]]
    area = 0
    
    while stack.any?
      x, y = stack.pop
      next if x < 0 || x >= @sheet_width || 
              y < 0 || y >= @sheet_height ||
              visited[y][x] || grid[y][x]
      
      visited[y][x] = true
      area += 1
      
      # Add neighbors
      stack << [x + 1, y] << [x - 1, y] << [x, y + 1] << [x, y - 1]
    end
    
    area
  end
end
