# 🖨️ Guia de Impressão

## Versão para Impressão Profissional

O otimizador gera automaticamente uma versão **otimizada para impressão**, perfeita para levar à oficina de marcenaria!

## 📄 Arquivo Gerado

Após executar a otimização, o arquivo é criado em:
```
output/print.html
```

## 🚀 Como Usar

### 1. Executar Otimização
```bash
ruby cut_optimizer.rb -f caixa.yml
```

### 2. Abrir Versão de Impressão
```bash
firefox output/print.html
# ou
xdg-open output/print.html
```

### 3. Imprimir
- **No navegador**: Clique no botão verde **"🖨️ IMPRIMIR"** ou pressione `Ctrl+P`
- **Configuração sugerida**: 
  - Tamanho: A4
  - Orientação: Retrato
  - Margens: Padrão (15mm)
  - Cores: Ativadas

## 📋 O que contém a versão de impressão?

### Página 1: Resumo do Projeto
- **Cabeçalho profissional** com título e data
- **Estatísticas gerais**:
  - Chapas utilizadas
  - Peças cortadas
  - Eficiência geral
  - Peças não alocadas
- **Instruções importantes** para marcenaria

### Páginas 2+: Uma página por chapa
Cada chapa contém:

#### 📊 Informações da Chapa
- Dimensões (largura × altura)
- Porcentagem de aproveitamento
- Número de peças

#### 📝 Tabela Detalhada de Peças
Cada linha contém:
- **☐** Checkbox para marcar peças cortadas
- **#** Número sequencial
- **ID** Identificador único
- **Identificação** Nome da peça
- **Largura** em mm
- **Altura** em mm
- **Posição (X, Y)** Coordenadas exatas
- **Obs.** Indicação se está rotacionada (↻)

#### 🎨 Diagrama Visual
- Layout SVG da chapa com todas as peças
- Cores para fácil identificação
- Escala adequada para impressão

#### 📏 Rodapé com Estatísticas
- Área utilizada
- Área desperdiçada

## 💡 Recursos Profissionais

### ✅ Caixas de Verificação
Cada peça tem uma caixa **☐** para marcar após o corte. Perfeito para controle na oficina!

### ↻ Indicador de Rotação
Peças rotacionadas são claramente marcadas com **↻ ROTACIONADA** em vermelho.

### 📐 Coordenadas Precisas
Cada peça mostra sua posição exata (X, Y) na chapa.

### 🎨 Diagrama Visual
SVG embutido mostra visualmente onde cortar cada peça.

### 📄 Quebra de Página
Cada chapa fica em sua própria página - ideal para imprimir!

## 🎯 Dicas para Uso na Oficina

1. **Imprima uma cópia para cada chapa**
   - Facilita o trabalho quando você tem várias chapas
   
2. **Marque as peças conforme corta**
   - Use as caixas ☐ para controle
   
3. **Confira as medidas antes de cortar**
   - Sempre verifique dimensões críticas
   
4. **Preste atenção nas rotações**
   - Peças com ↻ devem ser cortadas em 90°
   
5. **Use as coordenadas X,Y**
   - Ajuda a posicionar corretamente na chapa
   
6. **Mantenha para referência**
   - Guarde para projetos futuros similares

## 🖼️ Visualização na Tela

Antes de imprimir, você pode visualizar no navegador:
- Simula páginas A4
- Fundo cinza mostra separação de páginas
- Botão verde flutuante para impressão rápida
- Scroll para ver todas as chapas

## 🎨 CSS Otimizado

A versão de impressão usa CSS especial:
- `@page` define tamanho A4 e margens
- `page-break-before: always` para cada chapa
- Fontes otimizadas para legibilidade
- Cores preservadas na impressão
- Elementos desnecessários ocultos

## 📱 Também Funciona em Mobile

Abra no celular ou tablet e leve para a oficina!

## 🔄 Comparação com Versão Visual

| Característica | index.html | print.html |
|---------------|------------|------------|
| **Propósito** | Visualização interativa | Impressão profissional |
| **Layout** | Cards coloridos | Páginas A4 |
| **Tabelas** | Legendas laterais | Tabelas detalhadas |
| **Checkboxes** | ❌ Não | ✅ Sim |
| **Instruções** | Básicas | Completas |
| **Quebra de página** | Não | Sim (1 chapa/página) |
| **Botão imprimir** | Não | ✅ Grande e visível |

## 📦 Arquivos Relacionados

```
output/
├── index.html          ← Visualização interativa
├── print.html          ← VERSÃO PARA IMPRESSÃO ⭐
├── sheet_1.svg         ← SVG da chapa 1
├── sheet_2.svg         ← SVG da chapa 2
└── ...
```

## 🎓 Exemplo de Fluxo de Trabalho

1. **Planejamento**
   ```bash
   ruby cut_optimizer.rb -f projeto.yml
   ```

2. **Revisão**
   - Abra `index.html` para visualizar
   - Confira se está tudo correto

3. **Impressão**
   - Abra `print.html`
   - Clique em "🖨️ IMPRIMIR"
   - Configure impressora

4. **Oficina**
   - Leve as folhas impressas
   - Marque ☐ conforme corta
   - Use coordenadas para posicionar

5. **Controle de Qualidade**
   - Confira cada peça após cortar
   - Verifique dimensões críticas

## 🔧 Personalização

Se quiser customizar o layout de impressão, edite:
```
lib/report_generator.rb
```

Método: `generate_print_version`

Você pode ajustar:
- Tamanho das fontes
- Cores das tabelas
- Informações exibidas
- Layout dos diagramas
- Espaçamento

## ⚠️ Peças Não Alocadas

Se houver peças que não couberam, uma página adicional em vermelho é gerada com:
- Lista das peças não alocadas
- Sugestões de solução
- Cores de alerta

## 🌟 Benefícios

✅ **Profissional** - Layout limpo e organizado
✅ **Prático** - Checkboxes para controle
✅ **Completo** - Todas as informações necessárias
✅ **Portátil** - Formato A4 padrão
✅ **Econômico** - Uma chapa por página
✅ **Preciso** - Coordenadas e medidas exatas

---

**Agora você tem um plano de corte profissional, pronto para levar à oficina!** 🪚✨

