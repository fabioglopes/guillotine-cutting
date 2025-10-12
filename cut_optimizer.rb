#!/usr/bin/env ruby

require_relative 'lib/piece'
require_relative 'lib/sheet'
require_relative 'lib/cutting_optimizer'
require_relative 'lib/report_generator'
require_relative 'lib/input_loader'
require 'yaml'
require 'optparse'

class CutOptimizerCLI
  def initialize
    @options = {
      input_file: nil,
      allow_rotation: true,
      cutting_width: 3,
      export_json: false,
      export_svg: true,  # Gerar SVG por padrão
      auto_open: true,   # Abrir navegador automaticamente
      interactive: false,
      convert_to_yaml: nil
    }
  end

  def run(args)
    parse_options(args)

    if @options[:interactive]
      run_interactive
    elsif @options[:input_file]
      # Check if it's a STEP file
      if @options[:input_file] =~ /\.(step|stp)$/i
        # STEP files must be converted to YAML first
        output_file = @options[:convert_to_yaml] || @options[:input_file].gsub(/\.(step|stp)$/i, '.yml')
        convert_step_to_yaml(@options[:input_file], output_file)
      else
        # YAML files go directly to optimization
        run_from_file(@options[:input_file])
      end
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

      opts.on("-f", "--file ARQUIVO", "Arquivo YAML ou STEP com especificações") do |file|
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

      opts.on("-s", "--[no-]svg", "Exportar layouts em SVG (padrão: sim)") do |s|
        @options[:export_svg] = s
      end

      opts.on("-o", "--[no-]open", "Abrir navegador automaticamente (padrão: sim)") do |o|
        @options[:auto_open] = o
      end

      opts.on("--output ARQUIVO", "Nome do arquivo YAML de saída (para arquivos STEP)") do |output|
        @options[:convert_to_yaml] = output
      end

      opts.on("-h", "--help", "Mostrar esta mensagem") do
        puts opts
        exit
      end
    end.parse!(args)
  end

  def run_from_file(filename)
    loader = InputLoader.new
    data = loader.load_file(filename)

    unless data
      puts "Erro ao carregar arquivo:"
      loader.errors.each { |e| puts "  - #{e}" }
      exit 1
    end

    available_sheets = data[:sheets]
    required_pieces = data[:pieces]

    if available_sheets.empty?
      puts "\nErro: Nenhuma chapa disponível definida no arquivo YAML!"
      exit 1
    end

    if required_pieces.empty?
      puts "Erro: Nenhuma peça necessária definida!"
      exit 1
    end

    run_optimization(available_sheets, required_pieces)
  end

  def convert_step_to_yaml(step_file, output_file)
    require_relative 'lib/step_parser'
    
    # Parse STEP file directly
    parser = StepParser.new(step_file)
    
    unless parser.parse
      puts "Erro ao carregar arquivo STEP:"
      parser.errors.each { |e| puts "  - #{e}" }
      exit 1
    end

    if parser.parts.empty?
      puts "Erro: Nenhuma peça encontrada no arquivo STEP"
      exit 1
    end

    # Convert to pieces
    pieces_data = parser.to_pieces
    pieces = []
    pieces_data.each do |part_data|
      pieces << Piece.new(
        part_data[:id],
        part_data[:width],
        part_data[:height],
        part_data[:quantity],
        part_data[:label]
      )
    end

    # Generate YAML content
    yaml_content = generate_yaml_from_step(pieces)

    # Write to file
    begin
      File.write(output_file, yaml_content)
      puts "✅ Arquivo STEP convertido com sucesso!"
      puts ""
      puts "📄 Arquivo YAML criado: #{output_file}"
      puts ""
      puts parser.summary
      puts ""
      puts "📋 Próximos passos:"
      puts "  1. Edite #{output_file} para ajustar:"
      puts "     - Quantidades das peças (padrão: 1)"
      puts "     - Dimensões das chapas disponíveis"
      puts "     - Quantidade de chapas"
      puts ""
      puts "  2. Execute a otimização:"
      puts "     ruby cut_optimizer.rb -f #{output_file}"
    rescue => e
      puts "Erro ao salvar arquivo YAML: #{e.message}"
      exit 1
    end
  end

  def generate_yaml_from_step(pieces)
    yaml = "# Gerado automaticamente do arquivo STEP\n"
    yaml += "# Edite as quantidades e adicione as chapas disponíveis\n\n"
    yaml += "chapas_disponiveis:\n"
    yaml += "  - identificacao: \"Chapa MDF 15mm\"\n"
    yaml += "    largura: 2750  # ajuste conforme necessário\n"
    yaml += "    altura: 1850\n"
    yaml += "    quantidade: 3\n\n"
    yaml += "pecas_necessarias:\n"
    
    pieces.each do |piece|
      yaml += "  - identificacao: \"#{piece.label}\"\n"
      yaml += "    largura: #{piece.width}\n"
      yaml += "    altura: #{piece.height}\n"
      yaml += "    quantidade: 1  # ajuste conforme necessário\n"
      yaml += "\n"
    end
    
    yaml
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
      report_generator.generate_svg_report(@options[:auto_open])
    end

    puts "\n✓ Otimização concluída!"
  end
end

# Executa a CLI
if __FILE__ == $0
  cli = CutOptimizerCLI.new
  cli.run(ARGV)
end

