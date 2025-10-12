#!/usr/bin/env ruby

# Script de teste básico para verificar se tudo está funcionando

require_relative 'lib/piece'
require_relative 'lib/sheet'
require_relative 'lib/cutting_optimizer'
require_relative 'lib/report_generator'

puts "=== TESTE BÁSICO DO OTIMIZADOR ==="
puts "\nCriando chapas e peças de teste..."

# Cria uma chapa de 2000x1000mm
sheets = [
  Sheet.new('S1', 2000, 1000, 'Chapa de Teste')
]

# Cria algumas peças para cortar
pieces = [
  Piece.new('P1', 500, 300, 2, 'Peça Grande'),
  Piece.new('P2', 400, 250, 3, 'Peça Média'),
  Piece.new('P3', 300, 200, 2, 'Peça Pequena')
]

puts "\nChapas disponíveis:"
sheets.each { |s| puts "  - #{s.to_s}" }

puts "\nPeças necessárias:"
pieces.each { |p| puts "  - #{p.to_s} (quantidade: #{p.quantity})" }

puts "\n" + "=" * 60
puts "Executando otimização..."
puts "=" * 60

# Executa a otimização
optimizer = CuttingOptimizer.new(sheets, pieces)
optimizer.optimize(allow_rotation: true, cutting_width: 3)

# Gera relatório
report_generator = ReportGenerator.new(optimizer)
report_generator.generate_console_report

puts "\n✓ Teste concluído com sucesso!"
puts "\nAgora experimente com seu próprio arquivo:"
puts "  ruby cut_optimizer.rb -f exemplo.yml"
puts "\nOu use o modo interativo:"
puts "  ruby cut_optimizer.rb -i"

