#!/usr/bin/env ruby

require_relative 'lib/piece'
require_relative 'lib/sheet'
require_relative 'lib/cutting_optimizer'
require_relative 'lib/report_generator'
require 'yaml'
require 'optparse'

class CutOptimizerCLI
  def initialize
    @options = {
      input_file: nil,
      allow_rotation: true,
      cutting_width: 3,
      export_json: false,
      export_svg: false,
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
      opts.banner = "Uso: ruby cut_optimizer.rb [opções]"
      opts.separator ""
      opts.separator "Otimizador de cortes de chapas de madeira"
      opts.separator ""
      opts.separator "Opções:"

      opts.on("-f", "--file ARQUIVO", "Arquivo YAML com especificações das chapas e peças") do |file|
        @options[:input_file] = file
      end

      opts.on("-i", "--interactive", "Modo interativo") do
        @options[:interactive] = true
      end

      opts.on("-r", "--[no-]rotation", "Permitir rotação de peças (padrão: sim)") do |r|
        @options[:allow_rotation] = r
      end

      opts.on("-c", "--cutting-width MM", Integer, "Espessura do corte da serra em mm (padrão: 3)") do |w|
        @options[:cutting_width] = w
      end

      opts.on("-j", "--json", "Exportar relatório em JSON") do
        @options[:export_json] = true
      end

      opts.on("-s", "--svg", "Exportar layouts em SVG") do
        @options[:export_svg] = true
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

    available_sheets = parse_sheets(data['chapas_disponiveis'] || data['available_sheets'])
    required_pieces = parse_pieces(data['pecas_necessarias'] || data['required_pieces'])

    run_optimization(available_sheets, required_pieces)
  end

  def run_interactive
    puts "\n=== OTIMIZADOR DE CORTES DE MADEIRA ==="
    puts "\nVamos configurar suas chapas e peças...\n"

    # Chapas disponíveis
    puts "\n--- CHAPAS DISPONÍVEIS ---"
    available_sheets = []
    loop do
      print "\nAdicionar chapa? (s/n): "
      break unless gets.chomp.downcase == 's'

      print "Largura da chapa (mm): "
      width = gets.chomp.to_i

      print "Altura da chapa (mm): "
      height = gets.chomp.to_i

      print "Quantidade desta chapa: "
      quantity = gets.chomp.to_i

      print "Identificação/Label (opcional): "
      label = gets.chomp
      label = nil if label.empty?

      quantity.times do |i|
        sheet_id = "S#{available_sheets.length + 1}"
        sheet_label = label ? "#{label} ##{i + 1}" : nil
        available_sheets << Sheet.new(sheet_id, width, height, sheet_label)
      end

      puts "✓ #{quantity} chapa(s) adicionada(s)"
    end

    if available_sheets.empty?
      puts "Erro: Nenhuma chapa disponível!"
      exit 1
    end

    # Peças necessárias
    puts "\n--- PEÇAS NECESSÁRIAS ---"
    required_pieces = []
    loop do
      print "\nAdicionar peça? (s/n): "
      break unless gets.chomp.downcase == 's'

      print "Largura da peça (mm): "
      width = gets.chomp.to_i

      print "Altura da peça (mm): "
      height = gets.chomp.to_i

      print "Quantidade desta peça: "
      quantity = gets.chomp.to_i

      print "Identificação/Label: "
      label = gets.chomp

      piece_id = "P#{required_pieces.length + 1}"
      required_pieces << Piece.new(piece_id, width, height, quantity, label)

      puts "✓ Peça adicionada: #{quantity}x #{label} (#{width}x#{height}mm)"
    end

    if required_pieces.empty?
      puts "Erro: Nenhuma peça necessária!"
      exit 1
    end

    run_optimization(available_sheets, required_pieces)
  end

  def parse_sheets(sheets_data)
    return [] unless sheets_data

    sheets = []
    sheets_data.each_with_index do |data, idx|
      width = data['largura'] || data['width']
      height = data['altura'] || data['height']
      quantity = data['quantidade'] || data['quantity'] || 1
      label = data['identificacao'] || data['label']

      quantity.times do |i|
        sheet_id = "S#{idx + 1}.#{i + 1}"
        sheet_label = label ? "#{label} ##{i + 1}" : "Chapa #{idx + 1}.#{i + 1}"
        sheets << Sheet.new(sheet_id, width, height, sheet_label)
      end
    end
    sheets
  end

  def parse_pieces(pieces_data)
    return [] unless pieces_data

    pieces_data.map.with_index do |data, idx|
      width = data['largura'] || data['width']
      height = data['altura'] || data['height']
      quantity = data['quantidade'] || data['quantity'] || 1
      label = data['identificacao'] || data['label'] || "Peça #{idx + 1}"

      Piece.new("P#{idx + 1}", width, height, quantity, label)
    end
  end

  def run_optimization(available_sheets, required_pieces)
    optimizer = CuttingOptimizer.new(available_sheets, required_pieces)
    optimizer.optimize(
      allow_rotation: @options[:allow_rotation],
      cutting_width: @options[:cutting_width]
    )

    # Gera relatório
    report_generator = ReportGenerator.new(optimizer)
    report_generator.generate_console_report

    # Exportações opcionais
    if @options[:export_json]
      report_generator.generate_json_report
    end

    if @options[:export_svg]
      report_generator.generate_svg_report
    end

    puts "\n✓ Otimização concluída!"
  end
end

# Executa a CLI
if __FILE__ == $0
  cli = CutOptimizerCLI.new
  cli.run(ARGV)
end

