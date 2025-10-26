# 🎯 Guia Completo de Recursos

## 📊 Visão Geral dos Outputs

Quando você executa o otimizador, **4 tipos de arquivos** são gerados automaticamente:

```
output/
├── index.html     ← Visualização interativa (para navegador)
├── print.html     ← Versão para impressão (para oficina)  
├── sheet_1.svg    ← Layout visual da chapa 1
└── sheet_2.svg    ← Layout visual da chapa 2
```

## 🌐 index.html - Visualização Interativa

### Para que serve?
Visualização bonita e interativa no navegador para **revisar o plano de cortes**.

### Recursos principais:

#### 🖨️ Botão de Impressão (NOVO!)
- **Localização**: Canto superior direito, botão laranja
- **Texto**: "🖨️ VERSÃO PARA IMPRESSÃO"  
- **Função**: Abre `print.html` em nova aba
- **Design**: 
  - Cor laranja (#FF5722) chamativa
  - Efeito hover (sobe ao passar mouse)
  - Sempre visível (position: fixed)
  - Ícone de impressora 🖨️

#### 📊 Resumo com Estatísticas
- Chapas utilizadas
- Peças cortadas
- Eficiência geral (%)
- Peças não alocadas

#### 🎨 Cards das Chapas
- Disposição vertical (uma embaixo da outra)
- Informações de cada chapa
- Layout SVG embutido
- Botões de download individual
- Hover effects

#### 📱 Responsivo
- Se adapta ao tamanho da tela
- Funciona em desktop, tablet e mobile
- Grid flexível

### Quando usar?
- ✅ Revisar o plano de cortes no computador
- ✅ Compartilhar com cliente (envie o HTML)
- ✅ Verificar eficiência antes de cortar
- ✅ **Acessar rapidamente a versão de impressão**

---

## 📄 print.html - Versão para Impressão

### Para que serve?
Versão **profissional otimizada para papel A4**, perfeita para levar à oficina.

### Recursos principais:

#### 🖨️ Botão de Impressão
- **Localização**: Canto superior direito, botão verde
- **Texto**: "🖨️ IMPRIMIR"
- **Função**: Abre diálogo de impressão
- **Visível apenas na tela** (oculto ao imprimir)

#### 📋 Página 1: Resumo + Instruções
- Cabeçalho profissional
- Estatísticas do projeto
- Box amarelo com instruções importantes
- Data e hora de geração

#### 📄 Páginas 2+: Uma Chapa por Página
Cada chapa tem:

**Cabeçalho**
- Nome da chapa destacado

**Informações em Grid**
- Dimensões
- Aproveitamento (%)
- Número de peças

**Tabela Detalhada**
| ☐ | # | ID | Nome | L | A | Posição | Obs. |
|---|---|---|------|---|---|---------|------|

- ☐ = Checkbox para marcar ao cortar
- ↻ = Indicador de rotação (em vermelho)

**Diagrama Visual**
- SVG com layout das peças
- Cores para identificação

**Rodapé**
- Estatísticas de área

#### 🎨 Design Profissional
- Formato A4 (210×297mm)
- Margens de 15mm
- Fontes otimizadas
- Cores preservadas
- Quebra de página automática

### Quando usar?
- ✅ **Imprimir e levar para oficina**
- ✅ Marcar peças conforme corta (checkboxes)
- ✅ Referência física durante trabalho
- ✅ Guardar para projetos futuros
- ✅ Salvar como PDF

---

## 🎨 sheet_N.svg - Layouts Visuais

### Para que serve?
Representação gráfica visual de cada chapa com as peças posicionadas.

### Recursos principais:

#### 🎨 Visual Profissional
- Grid de fundo para referência
- 15 cores distintas para peças
- Sombras e efeitos
- Escala automática

#### 📊 Informações Completas
- Título da chapa
- Dimensões totais
- Cotas dimensionais (linhas tracejadas)
- Eficiência de aproveitamento

#### 🏷️ Labels nas Peças
- ID da peça
- Dimensões (largura × altura)
- Indicador de rotação (↻)

#### 📋 Legenda Lateral
Lista todas as peças com:
- Cor correspondente
- ID e nome
- Dimensões
- Posição (X, Y)
- Marcação de rotação
- Estatísticas finais

### Quando usar?
- ✅ Abrir individualmente no navegador
- ✅ Editar no Inkscape/Illustrator
- ✅ Importar em software CAD
- ✅ Imprimir em qualquer tamanho (vetorial)
- ✅ Compartilhar facilmente

---

## 🔄 Comparação Rápida

| Característica | index.html | print.html | sheet_N.svg |
|---------------|------------|------------|-------------|
| **Uso principal** | Revisar | Imprimir | Visualizar layout |
| **Botão impressão** | ✅ Para print.html | ✅ Imprimir direto | ❌ |
| **Layout** | Cards verticais | Páginas A4 | SVG único |
| **Checkboxes** | ❌ | ✅ | ❌ |
| **Instruções** | Básicas | Completas | Nenhuma |
| **Tabela detalhada** | ❌ | ✅ | ❌ |
| **Interativo** | ✅ Hover | ❌ | ✅ Hover |
| **Botões download** | ✅ | ❌ | ❌ |
| **Quebra página** | ❌ | ✅ | N/A |
| **Editable** | ❌ | ❌ | ✅ (vetorial) |

---

## 🎯 Fluxo de Trabalho Recomendado

### 1. **Execução**
```bash
ruby cut_optimizer.rb -f projeto.yml
```
↓ Gera todos os arquivos

### 2. **Revisão** (index.html)
- Navegador abre automaticamente
- Revise layouts e eficiência
- Veja botão laranja no canto

### 3. **Ajustes** (se necessário)
- Edite o arquivo YAML
- Execute novamente

### 4. **Impressão** (print.html)
- Clique no botão laranja **"🖨️ VERSÃO PARA IMPRESSÃO"**
- OU abra `output/print.html`
- Clique no botão verde **"🖨️ IMPRIMIR"**
- Configure impressora (A4, cores)

### 5. **Oficina** (papel impresso)
- Leve as folhas para oficina
- Marque checkboxes ☐ ao cortar
- Use coordenadas para posicionar
- Confira rotações (↻)

### 6. **Controle** (durante corte)
- Confira medidas críticas
- Marque peças cortadas
- Verifique qualidade

---

## 🎨 Anatomia do Botão de Impressão

### No index.html (Botão Laranja)

```html
<a href="print.html" class="print-version-btn" target="_blank">
  🖨️ VERSÃO PARA IMPRESSÃO
</a>
```

**Características:**
- Posição: Fixed (sempre visível)
- Cor: Laranja (#FF5722)
- Localização: Canto superior direito
- Efeito: Sobe ao passar mouse
- Ação: Abre print.html em nova aba

### No print.html (Botão Verde)

```html
<button class="print-button" onclick="window.print()">
  🖨️ IMPRIMIR
</button>
```

**Características:**
- Posição: Fixed (sempre visível na tela)
- Cor: Verde (#4CAF50)
- Localização: Canto superior direito
- Efeito: Escurece ao passar mouse
- Ação: Abre diálogo de impressão
- **Oculto ao imprimir** (CSS @media print)

---

## 💡 Dicas de Uso

### Para Revisar
1. Execute o otimizador
2. Navegador abre `index.html`
3. Revise os layouts
4. Use botão laranja para imprimir

### Para Imprimir
1. Clique no botão laranja (ou abra `print.html`)
2. Clique no botão verde
3. Configure: A4, Retrato, Cores
4. Imprima ou salve como PDF

### Para Editar SVG
1. Abra `sheet_N.svg` no Inkscape
2. Edite cores, textos, etc.
3. Salve e use editado

### Para Compartilhar
- **Cliente**: Envie `index.html` + `output/` completo
- **Marceneiro**: Imprima `print.html`
- **Arquivo**: Guarde todo o `output/` para referência

---

## ⚙️ Personalização

### Desabilitar botão de impressão
Edite `lib/report_generator.rb` e remova ou comente:
```ruby
<a href="print.html" class="print-version-btn" target="_blank">
```

### Mudar cor do botão
No CSS, altere:
```css
.print-version-btn {
  background: #FF5722;  /* Mude esta cor */
}
```

### Adicionar mais informações
Edite os métodos:
- `generate_html_index` - para index.html
- `generate_print_version` - para print.html
- `generate_svg_layout` - para SVGs

---

**Agora você conhece todos os recursos disponíveis!** 🎯🪚

