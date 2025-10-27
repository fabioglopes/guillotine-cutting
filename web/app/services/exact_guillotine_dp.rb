class ExactGuillotineDp
  attr_reader :available_sheets, :required_pieces, :used_sheets, :unplaced_pieces

  def initialize(available_sheets, required_pieces)
    @available_sheets = available_sheets
    @required_pieces = expand_pieces(required_pieces)
    @used_sheets = []
    @unplaced_pieces = []
  end

  def optimize(allow_rotation: true, cutting_width: 3, time_limit_s: 3.0)
    start = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    # Simple bounded exact attempt: if too many distinct sizes, bail out to heuristic
    distinct = @required_pieces.map { |p| [p.width, p.height] }.uniq
    if distinct.size > 15
      # Fallback: use guillotine heuristic to keep UX responsive
      heuristic = GuillotineOptimizer.new(@available_sheets, @required_pieces)
      heuristic.optimize(allow_rotation: allow_rotation, cutting_width: cutting_width)
      @used_sheets = heuristic.used_sheets
      @unplaced_pieces = heuristic.unplaced_pieces
      return
    end

    @available_sheets.each do |template|
      break if @required_pieces.empty?
      sheet = OptimizerSheet.new("#{template.id}-EX#{@used_sheets.length + 1}", template.width, template.height, "#{template.label} ##{@used_sheets.length + 1}")
      sheet.cutting_width = cutting_width

      # Tiny DP placeholder: pack by trying to fill rows exactly; if time exceeded, stop
      remaining = @required_pieces.dup
      y = 0
      while y < sheet.height && !remaining.empty?
        row_height = nil
        x = 0
        placed_any = false
        remaining.dup.each do |piece|
          row_height ||= piece.height
          next unless piece.height <= row_height
          if x + piece.width + cutting_width <= sheet.width && y + row_height + cutting_width <= sheet.height
            sheet.add_piece(piece, x, y, false)
            remaining.delete(piece)
            x += piece.width + cutting_width
            placed_any = true
          end
          if Process.clock_gettime(Process::CLOCK_MONOTONIC) - start > time_limit_s
            break
          end
        end
        break unless placed_any
        y += (row_height || 0) + cutting_width
        break if Process.clock_gettime(Process::CLOCK_MONOTONIC) - start > time_limit_s
      end

      placed_count = @required_pieces.length - remaining.length
      @required_pieces = remaining
      if placed_count > 0
        @used_sheets << sheet
      end

      break if Process.clock_gettime(Process::CLOCK_MONOTONIC) - start > time_limit_s
    end

    @unplaced_pieces = @required_pieces
  end

  private
  def expand_pieces(pieces)
    pieces.flat_map do |p|
      Array.new(p.quantity) do |i|
        OptimizerPiece.new("#{p.id}.#{i+1}", p.width, p.height, 1, p.label)
      end
    end
  end
end


