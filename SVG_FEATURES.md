# 🎨 Recursos dos SVGs Gerados

## O que foi melhorado?

### ✅ Geração e Abertura Automática
- **SVGs são gerados por padrão** em todas as otimizações
- **Navegador abre automaticamente** mostrando os layouts
- Não precisa mais usar a opção `-s` ou abrir manualmente
- Para desabilitar SVG, use: `--no-svg`
- Para desabilitar abertura automática, use: `--no-open`

### ✅ Visualização Aprimorada

#### 1. **Layout Profissional**
- Grid de fundo para referência visual
- Sombras e efeitos para melhor profundidade
- Cores distintas para cada peça (15 cores diferentes)
- Hover interativo nas peças

#### 2. **Informações Detalhadas**
Cada SVG contém:
- **Título e dimensões** da chapa
- **Porcentagem de aproveitamento**
- **Cotas dimensionais** (largura e altura da chapa)
- **ID e medidas** de cada peça
- **Indicador de rotação** (↻) para peças rotacionadas
- **Legenda completa** com todas as peças

#### 3. **Legenda Lateral**
A legenda mostra:
- Cor correspondente a cada peça
- ID e nome da peça
- Dimensões (largura × altura)
- Posição exata (coordenadas X, Y)
- Indicador se foi rotacionada
- Estatísticas totais (área utilizada e desperdiçada)

### ✅ Página HTML Interativa

Além dos SVGs individuais, é gerado um arquivo `index.html` que:

- **Visualiza todos os layouts** em uma página
- **Grid responsivo** que se adapta ao tamanho da tela
- **Resumo geral** com estatísticas:
  - Chapas utilizadas
  - Peças cortadas
  - Eficiência geral
  - Peças não alocadas
- **Cards interativos** para cada chapa
- **Botões de download** para cada SVG
- **Design moderno** com gradiente e animações
- **Pronto para impressão** (oculta elementos desnecessários ao imprimir)

## Como Usar

### Execução Básica
```bash
ruby cut_optimizer.rb -f caixa.yml
```

Isso irá:
1. Otimizar os cortes
2. Gerar SVGs na pasta `output/`
3. Criar `output/index.html`
4. **Abrir automaticamente no navegador** 🌐

O navegador abre sozinho! Você não precisa fazer nada. 🎉

### Se o navegador não abrir (raro)

```bash
# Linux
xdg-open output/index.html
# ou
firefox output/index.html

# macOS
open output/index.html

# Windows
start output/index.html
```

### Desabilitar SVG (se quiser)
```bash
ruby cut_optimizer.rb -f caixa.yml --no-svg
```

## Estrutura dos Arquivos Gerados

```
output/
├── index.html          # Página principal com todos os layouts
├── sheet_1.svg         # Layout da primeira chapa
├── sheet_2.svg         # Layout da segunda chapa
└── sheet_N.svg         # ... e assim por diante
```

## Recursos Visuais

### Cores das Peças
15 cores distintas rotacionam para identificar cada peça:
- Verde, Azul, Amarelo, Rosa, Roxo
- Ciano, Laranja, Marrom, Cinza, Verde-Limão
- Laranja-Escuro, Cinza-Claro, Azul-Índigo, Vermelho, Amarelo-Verde

### Indicadores Visuais

- **↻ (Seta circular)** - Peça foi rotacionada 90°
- **Grid de fundo** - Facilita estimativa de distâncias
- **Linhas tracejadas** - Cotas dimensionais
- **Hover effect** - Destaca a peça ao passar o mouse

### Informações nos SVGs

Cada peça mostra (se houver espaço):
- **ID** - Identificador único (P1.1, P1.2, etc.)
- **Dimensões** - Largura × Altura em mm
- **Nome** - Label descritivo da peça

Na legenda:
- Todas as informações acima
- Posição exata (X, Y)
- Se foi rotacionada

## Impressão e Exportação

### Imprimir os Layouts
1. Abra `index.html` no navegador
2. Use Ctrl+P (ou Cmd+P no Mac)
3. Escolha "Salvar como PDF" ou imprima direto

### Usar os SVGs

Os SVGs podem ser:
- **Abertos diretamente** no navegador
- **Editados** em programas como Inkscape, Adobe Illustrator
- **Importados** em softwares CAD
- **Impressos** em qualquer tamanho sem perda de qualidade
- **Compartilhados** facilmente (são arquivos de texto)

## Personalização

Para personalizar os SVGs, edite:
- `lib/report_generator.rb` - Método `generate_svg_layout`

Você pode ajustar:
- Cores das peças
- Tamanho das fontes
- Escala dos layouts
- Informações exibidas
- Estilo visual (CSS no SVG)

## Exemplo Real

Ao executar com `caixa.yml`, você verá:
- Quantas chapas são necessárias
- Como cortar cada peça
- Posição exata para cada corte
- Desperdício em cada chapa
- Visual profissional para levar para oficina

## Dicas

1. **Imprima o index.html** para ter referência física na oficina
2. **Use os SVGs no celular/tablet** durante o corte
3. **Compartilhe o HTML** com clientes para aprovar layouts
4. **Anote no SVG** (se editar) observações específicas
5. **Salve os outputs** para referência futura de projetos

---

**Os SVGs gerados são profissionais e prontos para uso em marcenaria!** 🎯

