# 🌍 Bilingual Support / Suporte Bilíngue

This optimizer supports **both English and Portuguese** field names in YAML files.

Este otimizador suporta nomes de campos em **inglês e português** nos arquivos YAML.

## 📝 Supported Fields / Campos Suportados

### Sheets / Chapas

| English | Português | Description |
|---------|-----------|-------------|
| `available_sheets` | `chapas_disponiveis` | Main sheets section |
| `label` | `identificacao` | Sheet name/label |
| `width` | `largura` | Sheet width (mm) |
| `height` | `altura` | Sheet height (mm) |
| `thickness` | `espessura` | Sheet thickness (mm) |
| `quantity` | `quantidade` | Number of sheets |

### Pieces / Peças

| English | Português | Description |
|---------|-----------|-------------|
| `required_pieces` | `pecas_necessarias` | Main pieces section |
| `label` | `identificacao` | Piece name/label |
| `width` | `largura` | Piece width (mm) |
| `height` | `altura` | Piece height (mm) |
| `thickness` | `espessura` | Piece thickness (mm) |
| `quantity` | `quantidade` | Number of pieces |

## 📄 Examples / Exemplos

### English Version

```yaml
available_sheets:
  - label: "MDF 15mm Sheet"
    width: 2750
    height: 1850
    thickness: 15
    quantity: 3

required_pieces:
  - label: "Shelf"
    width: 900
    height: 300
    thickness: 15
    quantity: 4
```

### Portuguese Version / Versão em Português

```yaml
chapas_disponiveis:
  - identificacao: "Chapa MDF 15mm"
    largura: 2750
    altura: 1850
    espessura: 15
    quantidade: 3

pecas_necessarias:
  - identificacao: "Prateleira"
    largura: 900
    altura: 300
    espessura: 15
    quantidade: 4
```

### Bilingual Version (from STEP) / Versão Bilíngue (do STEP)

```yaml
# Auto-generated from STEP file / Gerado automaticamente
available_sheets:  # chapas_disponiveis
  - label: "MDF 15mm Sheet"  # identificacao
    width: 2750  # largura
    height: 1850  # altura
    thickness: 15  # espessura
    quantity: 3  # quantidade

required_pieces:  # pecas_necessarias
  - label: "Shelf"  # identificacao
    width: 900  # largura
    height: 300  # altura
    thickness: 15  # espessura
    quantity: 4  # quantidade
```

## 🔄 Mixing Languages / Misturando Idiomas

You can mix English and Portuguese field names in the same file!

Você pode misturar nomes de campos em inglês e português no mesmo arquivo!

```yaml
available_sheets:  # Using English here
  - label: "My Sheet"
    largura: 2750     # Using Portuguese here
    height: 1850      # Using English here
    espessura: 15     # Using Portuguese here
    quantidade: 2     # Using Portuguese here
```

The optimizer will understand both! / O otimizador entenderá ambos!

## 🆕 Thickness Field / Campo Espessura

The **thickness** field is optional but recommended:

O campo **espessura** é opcional mas recomendado:

- ✅ Helps organize sheets by thickness
- ✅ Adds thickness info to labels automatically
- ✅ Makes reports clearer

Examples:

```yaml
# Without thickness / Sem espessura
- label: "MDF Sheet"
  width: 2750
  height: 1850

# With thickness / Com espessura
- label: "MDF Sheet"
  width: 2750
  height: 1850
  thickness: 15  # Adds "15mm" to label automatically
```

## 🎯 STEP File Conversion / Conversão de Arquivo STEP

When converting from STEP files, the output is **bilingual by default**:

Ao converter de arquivos STEP, a saída é **bilíngue por padrão**:

```bash
ruby cut_optimizer.rb -f myproject.step
# Creates bilingual YAML with English primary fields
# and Portuguese in comments
```

## 💡 Best Practices / Melhores Práticas

### For International Projects / Para Projetos Internacionais
Use **English** field names:
```yaml
available_sheets:
  - label: "Plywood 18mm"
    width: 2440
    height: 1220
    thickness: 18
```

### Para Projetos Nacionais / For National Projects
Use **Portuguese** field names:
```yaml
chapas_disponiveis:
  - identificacao: "Compensado 18mm"
    largura: 2440
    altura: 1220
    espessura: 18
```

### For STEP Conversions / Para Conversões STEP
The **bilingual format** is automatically generated:
```yaml
available_sheets:  # chapas_disponiveis
  - label: "..."  # identificacao
    width: ...    # largura
```

---

**Both languages work equally well! Choose what's comfortable for you.**

**Ambos os idiomas funcionam igualmente bem! Escolha o que for mais confortável para você.**

