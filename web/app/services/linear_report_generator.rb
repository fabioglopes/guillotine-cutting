# Report generator for linear cuts
require 'json'

class LinearReportGenerator
  def initialize(optimizer)
    @optimizer = optimizer
  end

  def generate_console_report
    puts "\n" + "=" * 80
    puts "RELATÓRIO DE OTIMIZAÇÃO DE CORTES LINEARES".center(80)
    puts "=" * 80

    # Summary
    puts "\n--- RESUMO ---"
    puts "Total de peças necessárias: #{@optimizer.total_pieces}"
    puts "Peças cortadas: #{@optimizer.total_pieces - @optimizer.unallocated_pieces.length}"
    puts "Peças não alocadas: #{@optimizer.unallocated_pieces.length}"
    puts "Barras utilizadas: #{@optimizer.used_bars.length}"
    puts "Eficiência geral: #{@optimizer.total_efficiency}%"
    puts "Desperdício total: #{@optimizer.total_waste}mm"

    # Details per bar
    @optimizer.used_bars.each_with_index do |bar, idx|
      puts "\n--- #{bar.label.upcase} ---"
      puts "Comprimento total: #{bar.length}mm"
      puts "Comprimento utilizado: #{bar.used_length}mm (#{bar.efficiency}%)"
      puts "Desperdício: #{bar.waste}mm"
      puts "Número de cortes: #{bar.cuts.length}"
      puts "\nCortes nesta barra:"
      
      bar.cuts.each_with_index do |cut, cut_idx|
        piece = cut[:piece]
        puts "  #{cut_idx + 1}. #{piece.label} [#{piece.id}]: #{cut[:length]}mm"
        puts "     Posição inicial: #{cut[:position]}mm"
        puts "     Posição final: #{cut[:position] + cut[:length]}mm"
      end

      # Visual representation
      puts "\nRepresentação visual (escala ~1:#{scale_factor(bar.length)}):"
      puts generate_bar_visual(bar)
    end

    # Unallocated pieces
    if @optimizer.unallocated_pieces.any?
      puts "\n" + "=" * 80
      puts "⚠️  PEÇAS NÃO ALOCADAS"
      puts "=" * 80
      puts "\nAs seguintes peças não puderam ser cortadas:"
      
      @optimizer.unallocated_pieces.each do |piece|
        puts "  • #{piece.label} [#{piece.id}]: #{piece.length}mm"
      end
      
      puts "\nSugestão: Adicione mais barras ou use barras mais longas."
    end

    puts "\n" + "=" * 80
  end

  def generate_json_report(output_file = 'output/linear_cuts.json')
    require 'fileutils'
    FileUtils.mkdir_p('output')

    report = {
      summary: {
        total_pieces: @optimizer.total_pieces,
        pieces_cut: @optimizer.total_pieces - @optimizer.unallocated_pieces.length,
        unallocated_pieces: @optimizer.unallocated_pieces.length,
        bars_used: @optimizer.used_bars.length,
        efficiency: @optimizer.total_efficiency,
        total_waste: @optimizer.total_waste
      },
      bars: @optimizer.used_bars.map do |bar|
        {
          id: bar.id,
          label: bar.label,
          length: bar.length,
          used_length: bar.used_length,
          waste: bar.waste,
          efficiency: bar.efficiency,
          cuts: bar.cuts.map do |cut|
            {
              piece_id: cut[:piece].id,
              piece_label: cut[:piece].label,
              length: cut[:length],
              position: cut[:position]
            }
          end
        }
      end,
      unallocated: @optimizer.unallocated_pieces.map do |piece|
        {
          id: piece.id,
          label: piece.label,
          length: piece.length
        }
      end
    }

    File.write(output_file, JSON.pretty_generate(report))
    puts "\n✅ Relatório JSON salvo: #{output_file}"
  end

  private

  def scale_factor(length)
    # Calculate appropriate scale for visualization
    if length <= 1000
      10
    elsif length <= 3000
      30
    elsif length <= 6000
      60
    else
      100
    end
  end

  def generate_bar_visual(bar)
    width = 70
    scale = bar.length.to_f / width

    visual = "0mm" + " " * (width - 6) + "#{bar.length}mm\n"
    visual += "|" + "-" * width + "|\n"

    # Create bar representation
    bar_repr = Array.new(width, ' ')
    
    bar.cuts.each_with_index do |cut, idx|
      start_pos = (cut[:position] / scale).round
      end_pos = ((cut[:position] + cut[:length]) / scale).round
      
      # Use letters to represent different pieces
      letter = ('A'.ord + (idx % 26)).chr
      
      (start_pos...end_pos).each do |pos|
        bar_repr[pos] = letter if pos < width
      end
    end

    visual += "|" + bar_repr.join + "|\n"
    visual += "|" + "-" * width + "|\n"

    # Add legend
    visual += "\nLegenda:\n"
    bar.cuts.each_with_index do |cut, idx|
      letter = ('A'.ord + (idx % 26)).chr
      visual += "  #{letter} = #{cut[:piece].label} (#{cut[:length]}mm)\n"
    end

    visual
  end
end

