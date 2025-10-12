# 🪚 Otimizador de Cortes de Chapas de Madeira

Um software em Ruby para otimizar o corte de chapas de madeira, ideal para marcenaria e projetos de móveis planejados.

## 📋 Características

- ✅ Otimização automática de cortes usando algoritmo Guillotine Bin Packing
- ✅ Suporte para rotação de peças (opcional)
- ✅ Consideração da espessura do corte da serra
- ✅ Relatórios detalhados em texto, JSON e SVG
- ✅ Modo interativo e por arquivo de configuração
- ✅ Cálculo de eficiência de aproveitamento das chapas
- ✅ Identificação de peças que não puderam ser alocadas

## 🚀 Como Usar

### Requisitos

- Ruby 2.7 ou superior

### Instalação

Clone o repositório ou baixe os arquivos para um diretório local.

```bash
cd cut-tables
```

### Modo 1: Arquivo de Configuração (Recomendado)

1. Crie um arquivo YAML com suas especificações (veja `exemplo.yml`):

```yaml
chapas_disponiveis:
  - identificacao: "Chapa MDF 15mm"
    largura: 2750  # em milímetros
    altura: 1850
    quantidade: 2

pecas_necessarias:
  - identificacao: "Prateleira"
    largura: 900
    altura: 300
    quantidade: 4
```

2. Execute o otimizador:

```bash
ruby cut_optimizer.rb -f exemplo.yml
```

### Modo 2: Interativo

```bash
ruby cut_optimizer.rb -i
```

O programa irá guiá-lo passo a passo para inserir chapas e peças.

### Opções Avançadas

```bash
# Desabilitar rotação de peças
ruby cut_optimizer.rb -f exemplo.yml --no-rotation

# Alterar espessura do corte (padrão: 3mm)
ruby cut_optimizer.rb -f exemplo.yml -c 4

# Exportar relatório em JSON
ruby cut_optimizer.rb -f exemplo.yml -j

# Exportar layouts visuais em SVG
ruby cut_optimizer.rb -f exemplo.yml -s

# Combinar opções
ruby cut_optimizer.rb -f exemplo.yml -j -s -c 3
```

### Ver todas as opções

```bash
ruby cut_optimizer.rb --help
```

## 📊 Entendendo o Relatório

O programa gera um relatório detalhado contendo:

1. **Resumo Geral**
   - Total de peças necessárias
   - Peças cortadas com sucesso
   - Chapas utilizadas
   - Eficiência geral de aproveitamento

2. **Detalhes por Chapa**
   - Dimensões da chapa
   - Lista de peças cortadas
   - Posição de cada peça (coordenadas X, Y)
   - Indicação de peças rotacionadas
   - Layout ASCII simplificado

3. **Peças Não Alocadas**
   - Lista de peças que não couberam nas chapas disponíveis
   - Sugestões de ação

## 🎯 Exemplo de Uso

```bash
ruby cut_optimizer.rb -f exemplo.yml -s
```

Saída:
```
=== Iniciando otimização de cortes ===
Total de peças a cortar: 22
Chapas disponíveis: 3
Espessura de corte (serra): 3mm
Rotação permitida: Sim
  Chapa Chapa MDF 15mm #1: 8 peças colocadas (73.45% utilizada)
  Chapa Chapa MDF 15mm #2: 10 peças colocadas (68.92% utilizada)
  Chapa Chapa Compensado #1: 4 peças colocadas (45.23% utilizada)

=== Otimização concluída ===
Chapas utilizadas: 3
Peças cortadas: 22
Peças não colocadas: 0

✓ Layout SVG salvo em: output/sheet_1.svg
✓ Layout SVG salvo em: output/sheet_2.svg
✓ Layout SVG salvo em: output/sheet_3.svg
```

## 🔧 Estrutura do Projeto

```
cut-tables/
├── cut_optimizer.rb          # Script principal (CLI)
├── lib/
│   ├── piece.rb              # Classe Piece (peça)
│   ├── sheet.rb              # Classe Sheet (chapa)
│   ├── cutting_optimizer.rb  # Motor de otimização
│   ├── guillotine_bin_packer.rb  # Algoritmo de empacotamento
│   └── report_generator.rb   # Gerador de relatórios
├── exemplo.yml               # Arquivo de exemplo
└── README.md                 # Este arquivo
```

## 🧮 Algoritmo

O software utiliza o algoritmo **Guillotine Bin Packing**, especialmente adequado para cortes em marcenaria porque:

- Simula cortes retos (como uma serra faz)
- Otimiza o aproveitamento do espaço
- Minimiza desperdício de material
- Considera a espessura do corte da serra

## 💡 Dicas

1. **Espessura do corte**: Ajuste o parâmetro `-c` de acordo com sua serra (circular: 3-4mm, esquadrejadeira: 2-3mm)

2. **Rotação de peças**: Mantenha ativada para melhor aproveitamento, mas desative se o veio da madeira for importante

3. **Margem de segurança**: Adicione 1-2mm nas dimensões das peças para compensar imperfeições

4. **Ordem de corte**: As peças maiores são cortadas primeiro para melhor otimização

5. **Visualização**: Use a opção `-s` para gerar arquivos SVG que você pode abrir no navegador ou imprimir

## 🤝 Contribuindo

Sugestões e melhorias são bem-vindas! Sinta-se livre para modificar o código conforme suas necessidades.

## 📝 Licença

Software livre para uso pessoal e comercial.

## 🎓 Para Desenvolvedores

### Usando como biblioteca

```ruby
require_relative 'lib/cutting_optimizer'
require_relative 'lib/sheet'
require_relative 'lib/piece'

# Definir chapas
sheets = [
  Sheet.new('S1', 2750, 1850, 'MDF 15mm')
]

# Definir peças
pieces = [
  Piece.new('P1', 900, 300, 4, 'Prateleira')
]

# Otimizar
optimizer = CuttingOptimizer.new(sheets, pieces)
optimizer.optimize(allow_rotation: true, cutting_width: 3)

# Acessar resultados
optimizer.used_sheets.each do |sheet|
  puts "Chapa: #{sheet.label}, Eficiência: #{sheet.efficiency}%"
end
```

---

Desenvolvido com ❤️ para marceneiros e entusiastas de marcenaria!

