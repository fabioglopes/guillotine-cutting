#!/usr/bin/env ruby
# Linear Cut Optimizer for 1D materials (tubes, bars, profiles)
# Otimizador de Cortes Lineares para materiais 1D

require_relative 'lib/linear_optimizer'
require_relative 'lib/linear_report_generator'
require 'yaml'
require 'optparse'

class LinearCutOptimizerCLI
  def initialize
    @options = {
      input_file: nil,
      cutting_width: 3,
      export_json: false,
      interactive: false
    }
  end

  def run(args)
    parse_options(args)

    if @options[:interactive]
      run_interactive
    elsif @options[:input_file]
      run_from_file(@options[:input_file])
    else
      puts "Erro: Especifique um arquivo de entrada com -f ou use modo interativo com -i"
      puts "Use --help para mais informações"
      exit 1
    end
  end

  private

  def parse_options(args)
    OptionParser.new do |opts|
      opts.banner = "Uso: ruby linear_cut_optimizer.rb [opções]"
      opts.separator ""
      opts.separator "Otimizador de cortes lineares (1D) - tubos, barras, perfis"
      opts.separator ""
      opts.separator "Opções:"

      opts.on("-f", "--file ARQUIVO", "Arquivo YAML com especificações") do |file|
        @options[:input_file] = file
      end

      opts.on("-i", "--interactive", "Modo interativo") do
        @options[:interactive] = true
      end

      opts.on("-c", "--cutting-width MM", Integer, "Espessura do corte em mm (padrão: 3)") do |w|
        @options[:cutting_width] = w
      end

      opts.on("-j", "--json", "Exportar relatório em JSON") do
        @options[:export_json] = true
      end

      opts.on("-h", "--help", "Mostrar esta mensagem") do
        puts opts
        exit
      end
    end.parse!(args)
  end

  def run_from_file(filename)
    unless File.exist?(filename)
      puts "Erro: Arquivo '#{filename}' não encontrado!"
      exit 1
    end

    begin
      data = YAML.load_file(filename)
    rescue => e
      puts "Erro ao ler arquivo YAML: #{e.message}"
      exit 1
    end

    # Parse bars (support both Portuguese and English)
    bars_data = data['barras_disponiveis'] || data['available_bars']
    bars = parse_bars(bars_data)

    # Parse pieces
    pieces_data = data['pecas_necessarias'] || data['required_pieces']
    pieces = parse_linear_pieces(pieces_data)

    if bars.empty?
      puts "Erro: Nenhuma barra disponível definida!"
      exit 1
    end

    if pieces.empty?
      puts "Erro: Nenhuma peça necessária definida!"
      exit 1
    end

    run_optimization(bars, pieces)
  end

  def run_interactive
    puts "\n=== OTIMIZADOR DE CORTES LINEARES (1D) ==="
    puts "\nPara tubos, barras, perfis, sarrafos, etc.\n"

    # Bars available
    puts "\n--- BARRAS DISPONÍVEIS ---"
    bars = []
    loop do
      print "\nAdicionar barra? (s/n): "
      break unless gets.chomp.downcase == 's'

      print "Comprimento da barra (mm): "
      length = gets.chomp.to_i

      print "Quantidade desta barra: "
      quantity = gets.chomp.to_i

      print "Identificação/Label (opcional): "
      label = gets.chomp
      label = nil if label.empty?

      quantity.times do |i|
        bar_id = "B#{bars.length + 1}"
        bar_label = label ? "#{label} ##{i + 1}" : "Barra #{bars.length + 1}"
        bars << LinearBar.new(bar_id, length, bar_label)
      end

      puts "✓ #{quantity} barra(s) adicionada(s)"
    end

    if bars.empty?
      puts "Erro: Nenhuma barra disponível!"
      exit 1
    end

    # Required pieces
    puts "\n--- PEÇAS NECESSÁRIAS ---"
    pieces = []
    loop do
      print "\nAdicionar peça? (s/n): "
      break unless gets.chomp.downcase == 's'

      print "Comprimento da peça (mm): "
      length = gets.chomp.to_i

      print "Quantidade desta peça: "
      quantity = gets.chomp.to_i

      print "Identificação/Label: "
      label = gets.chomp

      piece_id = "P#{pieces.length + 1}"
      pieces << LinearPiece.new(piece_id, length, quantity, label)

      puts "✓ Peça adicionada: #{quantity}x #{label} (#{length}mm)"
    end

    if pieces.empty?
      puts "Erro: Nenhuma peça necessária!"
      exit 1
    end

    run_optimization(bars, pieces)
  end

  def parse_bars(bars_data)
    return [] unless bars_data

    bars = []
    bars_data.each_with_index do |data, idx|
      length = data['comprimento'] || data['length']
      quantity = data['quantidade'] || data['quantity'] || 1
      label = data['identificacao'] || data['label']

      quantity.times do |i|
        bar_id = "B#{idx + 1}.#{i + 1}"
        bar_label = label ? "#{label} ##{i + 1}" : "Barra #{idx + 1}.#{i + 1}"
        bars << LinearBar.new(bar_id, length, bar_label)
      end
    end
    bars
  end

  def parse_linear_pieces(pieces_data)
    return [] unless pieces_data

    pieces_data.map.with_index do |data, idx|
      length = data['comprimento'] || data['length']
      quantity = data['quantidade'] || data['quantity'] || 1
      label = data['identificacao'] || data['label'] || "Peça #{idx + 1}"

      LinearPiece.new("P#{idx + 1}", length, quantity, label)
    end
  end

  def run_optimization(bars, pieces)
    optimizer = LinearOptimizer.new(bars, pieces)
    optimizer.optimize(cutting_width: @options[:cutting_width])

    # Generate report
    report_generator = LinearReportGenerator.new(optimizer)
    report_generator.generate_console_report

    # JSON export if requested
    if @options[:export_json]
      report_generator.generate_json_report
    end

    puts "\n✓ Otimização concluída!"
  end
end

# Run CLI
if __FILE__ == $0
  cli = LinearCutOptimizerCLI.new
  cli.run(ARGV)
end

