# 📐 Como Usar Arquivos STEP (CAD)

Este otimizador converte arquivos STEP (ISO-10303-21) em arquivos YAML para otimização.

## 🚀 Uso Simples

### 1. Converter STEP para YAML

```bash
# Conversão automática (gera arquivo.yml)
ruby cut_optimizer.rb -f "meu_projeto.step"

# Ou especifique o nome de saída
ruby cut_optimizer.rb -f "meu_projeto.step" --output "config.yml"

# Ou use o script helper
./converter_step.sh "meu_projeto.step"
```

### 2. Editar o YAML Gerado

O arquivo YAML gerado terá esta estrutura:

```yaml
chapas_disponiveis:
  - identificacao: "Chapa MDF 15mm"
    largura: 2750  # ajuste conforme necessário
    altura: 1850
    quantidade: 3

pecas_necessarias:
  - identificacao: "Part 1"
    largura: 700
    altura: 302
    quantidade: 1  # ajuste conforme necessário
  # ... mais peças ...
```

**Edite:**
- Dimensões e quantidade das chapas disponíveis
- Quantidades das peças (se precisar de múltiplas cópias)

### 3. Executar a Otimização

```bash
ruby cut_optimizer.rb -f "meu_projeto.yml"
```

## 📦 Exportar de Programas CAD

### OnShape
1. Abra seu Part Studio
2. Menu: **Export** → **STEP**
3. Selecione as peças
4. Baixe o arquivo .step

### SolidWorks
1. Arquivo → **Salvar Como**
2. Tipo: **STEP AP242 (.step, .stp)**

### Fusion 360
1. Menu: **File** → **Export**
2. Tipo: **STEP (.step, .stp)**

### FreeCAD
1. Arquivo → **Exportar**
2. Formato: **STEP with colors (*.step *.stp)**

## ✅ O Que o Parser Detecta

- **Extração automática de dimensões**: Calcula bounding box de cada peça
- **Múltiplas peças**: Lê todas as peças do arquivo
- **Conversão de unidades**: Converte de metros para milímetros
- **Dimensões 2D**: Usa as duas maiores dimensões (ignora espessura)

## 💡 Dicas

1. **Nomeie as peças no CAD**: Os nomes são preservados no YAML
2. **Agrupe por espessura**: Exporte peças de mesma espessura juntas
3. **Valide dimensões**: Sempre confira se as medidas estão corretas
4. **Ajuste quantidades**: Por padrão, cada peça tem quantidade 1

## 📝 Workflow Completo

```bash
# 1. Exporte do CAD para STEP

# 2. Converta para YAML
ruby cut_optimizer.rb -f "projeto.step"

# 3. Edite o YAML
nano projeto.yml

# 4. Otimize
ruby cut_optimizer.rb -f "projeto.yml"

# 5. Visualize os resultados
# Abre automaticamente: output/index.html
```

## ⚙️ Formatos Suportados

- **STEP AP242** (OnShape, SolidWorks modernos)
- **STEP AP214** (SolidWorks, CAD genéricos)
- **STEP AP203** (CAD mais antigos)
- Extensões: `.step` ou `.stp`

## 🐛 Problemas Comuns

**"No parts found"**
- Verifique se o arquivo contém sólidos
- Tente exportar novamente com opções diferentes

**Dimensões incorretas**
- Confira unidades no CAD antes de exportar
- O parser usa bounding box (pode não ser exato para formas complexas)

**Arquivo não abre**
- Certifique-se que é formato STEP válido (ISO-10303-21)
- Verifique permissões de leitura do arquivo

---

**Fluxo simples: STEP → YAML → Otimização → SVG! 🎉**

