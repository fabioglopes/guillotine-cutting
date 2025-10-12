# 🎉 Novas Funcionalidades / New Features

## Versão 3.2.0 - Espessura e Suporte Bilíngue

### ✨ 1. Campo de Espessura (Thickness Field)

Agora você pode especificar a espessura das chapas e peças!

```yaml
available_sheets:
  - label: "MDF 15mm"
    width: 2750
    height: 1850
    thickness: 15  # NOVO! / NEW!
    quantity: 3

required_pieces:
  - label: "Shelf"
    width: 900
    height: 300
    thickness: 15  # NOVO! / NEW!
    quantity: 4
```

**Benefícios:**
- 📊 Organização automática por espessura
- 🏷️ Labels mais informativos (adiciona espessura automaticamente)
- 📈 Relatórios mais claros

### ✨ 2. Agrupamento Automático por Espessura

Ao converter arquivos STEP, as peças são **automaticamente agrupadas por espessura**:

```bash
ruby cut_optimizer.rb -f projeto.step
```

**Saída:**
```
=== STEP File Analysis ===
Parts found: 12

📊 Peças agrupadas por espessura:
  • 10.0mm: 6 peça(s)
  • 15.0mm: 4 peça(s)
  • 18.0mm: 2 peça(s)
```

**YAML gerado:**
```yaml
available_sheets:
  # Uma entrada para cada espessura detectada
  - label: "MDF 10.0mm Sheet"
    thickness: 10.0
    # ...
  
  - label: "MDF 15.0mm Sheet"
    thickness: 15.0
    # ...

required_pieces:
  # Espessura: 10.0mm
  - label: "Part 1"
    thickness: 10.0
  # ...
  
  # Espessura: 15.0mm
  - label: "Part 5"
    thickness: 15.0
  # ...
```

### ✨ 3. Suporte Bilíngue (Português/Inglês)

Todos os campos suportam **português E inglês**:

#### Campos de Chapas:
- `available_sheets` = `chapas_disponiveis`
- `label` = `identificacao`
- `width` = `largura`
- `height` = `altura`
- `thickness` = `espessura`
- `quantity` = `quantidade`

#### Campos de Peças:
- `required_pieces` = `pecas_necessarias`
- `label` = `identificacao`
- `width` = `largura`
- `height` = `altura`
- `thickness` = `espessura`
- `quantity` = `quantidade`

**Você pode usar QUALQUER um:**

```yaml
# Português
chapas_disponiveis:
  - identificacao: "MDF 15mm"
    largura: 2750
    espessura: 15

# Inglês
available_sheets:
  - label: "MDF 15mm"
    width: 2750
    thickness: 15

# Misturado!
available_sheets:
  - label: "MDF 15mm"
    largura: 2750  # português
    thickness: 15   # inglês
```

### ✨ 4. YAMLs Bilíngues do STEP

Arquivos STEP são convertidos para YAMLs **bilíngues**:

```yaml
# Auto-generated from STEP file / Gerado automaticamente
available_sheets:  # chapas_disponiveis
  - label: "MDF 10.0mm Sheet"  # identificacao
    width: 2750  # largura - adjust as needed / ajuste conforme necessário
    height: 1850  # altura
    thickness: 10.0  # espessura
    quantity: 3  # quantidade
```

**Benefícios:**
- 🌍 Útil para projetos internacionais
- 📖 Facilita aprendizado
- 🔄 Compatível com ambos os idiomas

## 📦 Exemplos Incluídos

### English Example
- `example_simple.yml` - Exemplo simples em inglês

### Portuguese Example
- `exemplo_simples.yml` - Exemplo simples em português

### Bilingual Example (from STEP)
```bash
ruby cut_optimizer.rb -f "projeto.step"
# Gera YAML bilíngue automaticamente
```

## 🚀 Como Usar

### 1. Converter STEP com Espessuras
```bash
ruby cut_optimizer.rb -f "projeto.step" --output "config.yml"
```

Detecta automaticamente:
- ✅ Todas as espessuras
- ✅ Agrupa peças por espessura
- ✅ Cria chapas para cada espessura
- ✅ Gera YAML bilíngue

### 2. Usar Campos em Inglês
```yaml
# arquivo: project.yml
available_sheets:
  - label: "Plywood 18mm"
    width: 2440
    height: 1220
    thickness: 18
    quantity: 5
```

```bash
ruby cut_optimizer.rb -f project.yml
```

### 3. Usar Campos em Português
```yaml
# arquivo: projeto.yml
chapas_disponiveis:
  - identificacao: "Compensado 18mm"
    largura: 2440
    altura: 1220
    espessura: 18
    quantidade: 5
```

```bash
ruby cut_optimizer.rb -f projeto.yml
```

### 4. Misturar Idiomas
```yaml
# Funciona perfeitamente!
available_sheets:
  - label: "My Sheet"
    largura: 2750      # português
    height: 1850       # inglês
    espessura: 15      # português
    quantity: 3        # inglês
```

## 📊 Relatórios Melhorados

### Labels com Espessura
Quando você especifica espessura, ela é adicionada automaticamente aos labels:

```yaml
# YAML
- label: "Side Panel"
  thickness: 18

# Relatório
Side Panel (18mm) [P1.1]: 800x400mm
```

### Chapas com Espessura
```yaml
# YAML
- label: "MDF Sheet"
  thickness: 15

# Relatório
--- MDF SHEET 15MM #1 ---
```

## 💡 Dicas

1. **Sempre especifique espessura**: Torna relatórios mais claros
2. **Use inglês para projetos internacionais**: Facilita compartilhamento
3. **Use português para projetos locais**: Mais familiar
4. **YAMLs do STEP são bilíngues**: Melhor dos dois mundos

## 🔄 Compatibilidade

- ✅ Todos os YAMLs antigos continuam funcionando
- ✅ Campo `thickness`/`espessura` é opcional
- ✅ Sem breaking changes
- ✅ Totalmente retrocompatível

## 📚 Mais Informações

- [USO_STEP.md](USO_STEP.md) - Guia completo STEP
- [BILINGUAL_SUPPORT.md](BILINGUAL_SUPPORT.md) - Suporte bilíngue detalhado
- [README.md](README.md) - Documentação principal

---

**Versão**: 3.2.0  
**Data**: 2025-10-12  
**Status**: ✅ Estável / Stable

