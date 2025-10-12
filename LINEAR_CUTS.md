# 📏 Otimizador de Cortes Lineares (1D)
## Linear Cut Optimizer for Tubes, Bars, and Profiles

Otimizador especializado para cortes em **materiais lineares** (1D), ideal para:

- 🔲 **Tubos quadrados/retangulares**
- ⭕ **Tubos redondos**
- 📏 **Barras de aço/alumínio**
- 🪵 **Sarrafos de madeira**
- 🔧 **Perfis metálicos**
- 🚪 **Trilhos, canos, etc.**

## 🚀 Como Usar

### Modo 1: Arquivo YAML

Create o arquivo com suas barras e peças:

```yaml
# Barras disponíveis
barras_disponiveis:
  - identificacao: "Tubo quadrado 30x30mm"
    comprimento: 6000  # mm
    quantidade: 5

# Peças necessárias
pecas_necessarias:
  - identificacao: "Montante"
    comprimento: 2100
    quantidade: 4
  
  - identificacao: "Travessa"
    comprimento: 1500
    quantidade: 6
```

Execute:

```bash
ruby linear_cut_optimizer.rb -f exemplo_tubos.yml
```

### Modo 2: Interativo

```bash
ruby linear_cut_optimizer.rb -i
```

O programa perguntará:
1. Comprimento e quantidade das barras disponíveis
2. Comprimento e quantidade das peças necessárias

### Modo 3: Com Exportação JSON

```bash
ruby linear_cut_optimizer.rb -f exemplo_tubos.yml -j
```

Gera `output/linear_cuts.json` com todos os dados.

## 📊 Exemplo de Relatório

```
=== RESUMO ===
Total de peças necessárias: 30
Peças cortadas: 29
Peças não alocadas: 1
Barras utilizadas: 5
Eficiência geral: 96.07%
Desperdício total: 1178mm

--- TUBO QUADRADO 30X30MM #1 ---
Comprimento total: 6000mm
Comprimento utilizado: 5706mm (95.1%)
Desperdício: 294mm

Cortes nesta barra:
  1. Montante [P1.1]: 2100mm (0-2100mm)
  2. Montante [P1.2]: 2100mm (2103-4203mm)
  3. Travessa [P2.1]: 1500mm (4206-5706mm)

Representação visual:
|AAAAAAABBBBBBBBCCCCCC   |
```

## 📝 Formato YAML (Bilíngue)

### Português / English

```yaml
# Barras disponíveis / Available bars
barras_disponiveis:  # available_bars
  - identificacao: "Tubo 30x30"  # label
    comprimento: 6000  # length (mm)
    quantidade: 5  # quantity

# Peças necessárias / Required pieces
pecas_necessarias:  # required_pieces
  - identificacao: "Montante"  # label
    comprimento: 2100  # length (mm)
    quantidade: 4  # quantity
```

**Campos suportados:**

| Português | English | Descrição |
|-----------|---------|-----------|
| `barras_disponiveis` | `available_bars` | Barras disponíveis |
| `pecas_necessarias` | `required_pieces` | Peças a cortar |
| `identificacao` | `label` | Nome da barra/peça |
| `comprimento` | `length` | Comprimento em mm |
| `quantidade` | `quantity` | Quantidade |

## 🎯 Algoritmo

Usa **First Fit Decreasing (FFD)**:
1. Ordena peças por comprimento (maior → menor)
2. Para cada peça, tenta colocar na primeira barra que couber
3. Se não couber em nenhuma barra usada, usa uma nova
4. Considera espessura de corte entre peças

**Vantagens:**
- ✅ Otimização próxima do ótimo (~90-95%)
- ✅ Rápido (linear)
- ✅ Minimiza desperdício
- ✅ Minimiza número de barras

## 🔧 Opções

```bash
ruby linear_cut_optimizer.rb [opções]

Opções:
  -f, --file ARQUIVO      Arquivo YAML com barras e peças
  -i, --interactive       Modo interativo
  -c, --cutting-width MM  Espessura do corte (padrão: 3mm)
  -j, --json              Exportar JSON
  -h, --help              Mostrar ajuda
```

## 💡 Exemplos Práticos

### Estrutura Metálica

```yaml
# exemplo_estrutura.yml
barras_disponiveis:
  - identificacao: "Tubo quadrado 50x50x2mm"
    comprimento: 6000
    quantidade: 10

pecas_necessarias:
  - identificacao: "Coluna"
    comprimento: 2800
    quantidade: 4
  - identificacao: "Viga"
    comprimento: 3500
    quantidade: 6
  - identificacao: "Contraventamento"
    comprimento: 1200
    quantidade: 8
```

### Deck de Madeira

```yaml
# exemplo_deck.yml
barras_disponiveis:
  - identificacao: "Tábua 15cm"
    comprimento: 5000
    quantidade: 20

pecas_necessarias:
  - identificacao: "Tábua comprida"
    comprimento: 4500
    quantidade: 15
  - identificacao: "Tábua curta"
    comprimento: 2200
    quantidade: 25
```

### Tubulação Hidráulica

```yaml
# exemplo_tubos_pvc.yml
barras_disponiveis:
  - identificacao: "Tubo PVC 1/2 polegada"
    comprimento: 6000
    quantidade: 15

pecas_necessarias:
  - identificacao: "Alimentação"
    comprimento: 3200
    quantidade: 5
  - identificacao: "Ramal"
    comprimento: 1800
    quantidade: 10
  - identificacao: "Ligação"
    comprimento: 800
    quantidade: 20
```

## 📈 Dicas para Melhor Otimização

1. **Espessura de corte realista**
   - Serra circular: 3-4mm
   - Serra fita: 2-3mm
   - Disco de corte: 3-5mm

2. **Ordem das peças**
   - O algoritmo já ordena automaticamente
   - Peças maiores são cortadas primeiro

3. **Margem de segurança**
   - Adicione 1-2mm no comprimento das peças
   - Compensa imperfeições e ajustes

4. **Sobrando material?**
   - Reduza quantidade de barras
   - Ou use barras menores/mais baratas

5. **Peças não alocadas?**
   - Adicione mais barras
   - Ou use barras mais longas

## 🆚 Diferenças para Otimizador 2D

| Característica | Linear (1D) | Chapas (2D) |
|----------------|-------------|-------------|
| **Dimensões** | Apenas comprimento | Largura × Altura |
| **Rotação** | Não aplicável | Sim (90°) |
| **Algoritmo** | First Fit Decreasing | Guillotine Bin Packing |
| **Complexidade** | Mais simples | Mais complexo |
| **Uso** | Tubos, barras | Chapas, placas |
| **Eficiência** | 90-98% | 70-85% |

## 🎨 Visualização

O otimizador gera **representação visual ASCII** de cada barra:

```
0mm                                    6000mm
|--------------------------------------|
|AAAABBBBBBCCCCCC                      |
|--------------------------------------|

Legenda:
  A = Montante (2100mm)
  B = Travessa (1500mm)
  C = Diagonal (800mm)
```

## 📤 Exportação JSON

Com a opção `-j`, gera arquivo JSON:

```json
{
  "summary": {
    "total_pieces": 30,
    "pieces_cut": 29,
    "bars_used": 5,
    "efficiency": 96.07,
    "total_waste": 1178
  },
  "bars": [
    {
      "id": "B1.1",
      "label": "Tubo 30x30 #1",
      "length": 6000,
      "used_length": 5706,
      "waste": 294,
      "cuts": [...]
    }
  ]
}
```

## 🔗 Ver Também

- [README.md](README.md) - Otimizador 2D (chapas)
- [exemplo_tubos.yml](exemplo_tubos.yml) - Exemplo tubos
- [exemplo_sarrafos.yml](exemplo_sarrafos.yml) - Exemplo madeira

## 🎓 Quando Usar Cada Otimizador?

### Use o **Otimizador Linear** (1D) para:
- ✅ Tubos (quadrados, redondos, retangulares)
- ✅ Barras de aço/alumínio
- ✅ Sarrafos de madeira
- ✅ Perfis metálicos
- ✅ Trilhos, canos, vigas
- ✅ Qualquer material com apenas **1 dimensão relevante**

### Use o **Otimizador 2D** para:
- ✅ Chapas de madeira (MDF, compensado)
- ✅ Placas metálicas
- ✅ Vidros
- ✅ Acrílico
- ✅ Qualquer material com **2 dimensões** (largura × altura)

---

**Desenvolvido com ❤️ para serralheiros, marceneiros e construtores!**

