# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

puts "🌱 Criando dados de exemplo..."

# Limpar dados existentes
Project.destroy_all

# Projeto 1: Armário de Cozinha
project1 = Project.create!(
  name: "Armário de Cozinha",
  description: "Projeto completo de armário de cozinha com múltiplas prateleiras e portas",
  allow_rotation: true,
  cutting_width: 3,
  status: 'draft'
)

# Chapas para projeto 1
project1.sheets.create!([
  { label: "MDF 15mm", width: 2750, height: 1850, quantity: 2 },
  { label: "Compensado", width: 2200, height: 1600, quantity: 1 }
])

# Peças para projeto 1
project1.pieces.create!([
  { label: "Prateleira Grande", width: 900, height: 300, quantity: 4 },
  { label: "Prateleira Média", width: 600, height: 300, quantity: 6 },
  { label: "Lateral Armário", width: 1800, height: 400, quantity: 2 },
  { label: "Porta", width: 700, height: 1400, quantity: 2 },
  { label: "Tampa Superior", width: 950, height: 450, quantity: 1 },
  { label: "Fundo", width: 900, height: 350, quantity: 3 },
  { label: "Divisória", width: 400, height: 800, quantity: 4 }
])

puts "✅ Projeto 1 criado: #{project1.name}"

# Projeto 2: Caixa Simples
project2 = Project.create!(
  name: "Caixa de Armazenamento",
  description: "Caixa simples para armazenamento com tampa",
  allow_rotation: true,
  cutting_width: 3,
  status: 'draft'
)

# Chapas para projeto 2
project2.sheets.create!([
  { label: "MDF 12mm", width: 1200, height: 800, quantity: 1 }
])

# Peças para projeto 2
project2.pieces.create!([
  { label: "Lateral", width: 400, height: 300, quantity: 2 },
  { label: "Frente/Trás", width: 500, height: 300, quantity: 2 },
  { label: "Fundo", width: 500, height: 400, quantity: 1 },
  { label: "Tampa", width: 520, height: 420, quantity: 1 }
])

puts "✅ Projeto 2 criado: #{project2.name}"

# Projeto 3: Mesa de Centro (já otimizado - simulado)
project3 = Project.create!(
  name: "Mesa de Centro",
  description: "Mesa de centro moderna com prateleira inferior",
  allow_rotation: true,
  cutting_width: 3,
  status: 'completed',
  sheets_used: 2,
  pieces_placed: 6,
  pieces_total: 6,
  efficiency: 78.5
)

# Chapas para projeto 3
project3.sheets.create!([
  { label: "MDF 18mm", width: 2750, height: 1850, quantity: 2 }
])

# Peças para projeto 3
project3.pieces.create!([
  { label: "Tampo", width: 1200, height: 600, quantity: 1 },
  { label: "Prateleira Inferior", width: 1100, height: 550, quantity: 1 },
  { label: "Lateral", width: 600, height: 400, quantity: 2 },
  { label: "Travessa", width: 1100, height: 100, quantity: 2 }
])

puts "✅ Projeto 3 criado: #{project3.name} (simulado como concluído)"

puts ""
puts "🎉 Seeds concluídos!"
puts "Total de projetos: #{Project.count}"
puts "Total de chapas: #{Sheet.count}"
puts "Total de peças: #{Piece.count}"
