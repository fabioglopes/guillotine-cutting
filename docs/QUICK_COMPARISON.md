# 🔄 Comparação Rápida - Qual Otimizador Usar?

## 🎯 Escolha o Otimizador Correto

### 📏 Use o **Otimizador Linear (1D)**

**Comando:** `ruby linear_cut_optimizer.rb -f arquivo.yml`

**Para materiais lineares** (apenas comprimento):

| Material | Exemplo | Medida |
|----------|---------|--------|
| 🔲 Tubos quadrados | 30×30mm, 40×40mm | Comprimento |
| ⭕ Tubos redondos | Ø 25mm, Ø 50mm | Comprimento |
| 📏 Barras metálicas | Aço 1/2", alumínio 20mm | Comprimento |
| 🪵 Sarrafos/ripas | 3×5cm, 2×10cm | Comprimento |
| 🔧 Perfis | U, L, T metálicos | Comprimento |
| 🚪 Trilhos/canos | PVC, ferro | Comprimento |

**Características:**
- ✅ Apenas 1 dimensão (comprimento)
- ✅ Não há rotação
- ✅ Eficiência: 90-98%
- ✅ Algoritmo: First Fit Decreasing
- ✅ Rápido e simples

**Exemplo YAML:**
```yaml
barras_disponiveis:
  - identificacao: "Tubo 30x30"
    comprimento: 6000  # mm
    quantidade: 10

pecas_necessarias:
  - identificacao: "Montante"
    comprimento: 2100
    quantidade: 8
```

---

### 📐 Use o **Otimizador 2D**

**Comando:** `ruby cut_optimizer.rb -f arquivo.yml`

**Para materiais planares** (largura × altura):

| Material | Exemplo | Medidas |
|----------|---------|---------|
| 🪵 Chapas de madeira | MDF, compensado, OSB | Largura × Altura |
| 🔩 Placas metálicas | Aço, alumínio | Largura × Altura |
| 🪟 Vidros | Temperado, comum | Largura × Altura |
| 🔲 Acrílico/Plástico | PMMA, policarbonato | Largura × Altura |
| 📋 Placas em geral | Qualquer material plano | Largura × Altura |

**Características:**
- ✅ 2 dimensões (largura × altura)
- ✅ Rotação 90° disponível
- ✅ Eficiência: 70-85%
- ✅ Algoritmo: Guillotine Bin Packing
- ✅ Importa CAD (STEP)

**Exemplo YAML:**
```yaml
available_sheets:
  - label: "MDF 15mm"
    width: 2750
    height: 1850
    thickness: 15
    quantity: 5

required_pieces:
  - label: "Prateleira"
    width: 900
    height: 300
    thickness: 15
    quantity: 10
```

---

## 📊 Comparação Lado a Lado

| Característica | Linear (1D) | Chapas (2D) |
|----------------|-------------|-------------|
| **Dimensões** | Comprimento | Largura × Altura |
| **Rotação** | ❌ Não aplicável | ✅ Sim (90°) |
| **Import CAD** | ❌ Não | ✅ STEP files |
| **Eficiência típica** | 90-98% | 70-85% |
| **Algoritmo** | First Fit Decreasing | Guillotine Bin Packing |
| **Complexidade** | Simples (1D) | Complexa (2D) |
| **Tempo execução** | Muito rápido | Rápido |
| **Visualização** | ASCII bars | SVG + HTML |
| **Export** | JSON | JSON + SVG + HTML |
| **Bilíngue** | ✅ PT/EN | ✅ PT/EN |

## 🎓 Exemplos Práticos

### Projeto: Estrutura Metálica

**Use:** Otimizador Linear (1D)

**Por quê?** Tubos e barras (apenas comprimento)

```bash
ruby linear_cut_optimizer.rb -f estrutura.yml
```

---

### Projeto: Armário de Cozinha

**Use:** Otimizador 2D

**Por quê?** Chapas de MDF (largura × altura)

```bash
ruby cut_optimizer.rb -f armario.yml
```

---

### Projeto: Deck de Madeira

**Use:** Otimizador Linear (1D)

**Por quê?** Tábuas/sarrafos (apenas comprimento)

```bash
ruby linear_cut_optimizer.rb -f deck.yml
```

---

### Projeto: Mesa com Gavetas

**Use:** Otimizador 2D + Import CAD

**Por quê?** Peças planas de MDF

```bash
# 1. Exportar CAD para STEP
# 2. Converter para YAML
ruby cut_optimizer.rb -f mesa.step

# 3. Editar e otimizar
ruby cut_optimizer.rb -f mesa.yml
```

---

## 💡 Dicas

### Quando usar Linear (1D)?
✅ Material tem **apenas 1 dimensão relevante** (comprimento)
✅ Tubos, barras, perfis, sarrafos
✅ Eficiência alta é importante
✅ Visualização simples é suficiente

### Quando usar 2D?
✅ Material tem **2 dimensões** (largura × altura)
✅ Chapas, placas, vidros
✅ Precisa importar do CAD
✅ Quer visualização SVG bonita
✅ Quer versão para impressão

## 🔗 Links Úteis

- **[README.md](README.md)** - Documentação geral
- **[LINEAR_CUTS.md](LINEAR_CUTS.md)** - Guia completo Linear (1D)
- **[USO_STEP.md](USO_STEP.md)** - Import CAD para 2D
- **[BILINGUAL_SUPPORT.md](BILINGUAL_SUPPORT.md)** - Suporte PT/EN

## ❓ Ainda com dúvida?

### Pergunta: "Tenho tubos E chapas no projeto"
**Resposta:** Use os dois otimizadores!
```bash
ruby linear_cut_optimizer.rb -f tubos.yml
ruby cut_optimizer.rb -f chapas.yml
```

### Pergunta: "Meu material é 3D (bloco sólido)"
**Resposta:** Nenhum dos dois. Estes otimizadores são para 1D e 2D apenas.

### Pergunta: "Posso misturar espessuras diferentes?"
**Resposta:** 
- **Linear:** Sim, mas cada barra é independente
- **2D:** Sim, use o campo `thickness` para organizar

---

**Escolha o otimizador certo e economize material! 💰**

