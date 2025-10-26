# 🪚 Guia Completo - Otimizador de Cortes

> Guia consolidado com todas as instruções de uso do sistema.

## 📑 Índice

1. [Instalação](#instalação)
2. [Aplicação Web (Rails)](#aplicação-web-rails)
3. [Linha de Comando (CLI)](#linha-de-comando-cli)
4. [Uso de Arquivos STEP (CAD)](#uso-de-arquivos-step-cad)
5. [Cortes Lineares (1D)](#cortes-lineares-1d)
6. [Impressão de Resultados](#impressão-de-resultados)
7. [Solução de Problemas](#solução-de-problemas)

---

## Instalação

### Requisitos
- Ruby 3.4+ (ou 2.7+ para CLI)
- Rails 8.1+ (apenas para aplicação web)

### Verificar Ruby
```bash
ruby --version
```

### Instalar Rails (opcional - apenas para web)
```bash
gem install rails --no-document
```

---

## Aplicação Web (Rails)

### 🚀 Início Rápido

```bash
cd web
./quick_start.sh
```

Ou manualmente:
```bash
cd web
bundle install
bin/rails db:create db:migrate db:seed
bin/dev
```

Acesse: **http://localhost:3000**

### Criar Novo Projeto

#### Opção 1: Upload de Arquivo
1. Clique em "Novo Projeto"
2. Aba "Upload de Arquivo"
3. Faça upload de YAML ou STEP
4. Preencha nome e configurações
5. Clique em "Criar Projeto"

#### Opção 2: Configuração Manual
1. Clique em "Novo Projeto"
2. Aba "Configurar Manualmente"
3. Adicione chapas (botão "+")
   - Identificação, largura, altura, quantidade
4. Adicione peças (botão "+")
   - Identificação, largura, altura, quantidade
5. Clique em "Criar Projeto"

### Processar Otimização
1. Abra o projeto
2. Clique em "▶️ Processar Otimização"
3. Aguarde (auto-refresh)
4. Veja resultados com SVGs e estatísticas

### Downloads
- **print.html** - Versão para impressão A4
- **index.html** - Visualização interativa
- **SVGs** - Layouts individuais das chapas

---

## Linha de Comando (CLI)

### Uso Básico

#### 1. Com Arquivo YAML
```bash
ruby cut_optimizer.rb -f exemplo.yml
```

#### 2. Com Arquivo STEP (CAD)
```bash
# Converte STEP para YAML
ruby cut_optimizer.rb -f projeto.step

# Edite o YAML gerado e execute
ruby cut_optimizer.rb -f projeto.yml
```

#### 3. Modo Interativo
```bash
ruby cut_optimizer.rb -i
```

### Opções Disponíveis

```bash
# Desabilitar rotação
ruby cut_optimizer.rb -f exemplo.yml --no-rotation

# Alterar espessura do corte (padrão: 3mm)
ruby cut_optimizer.rb -f exemplo.yml -c 4

# Exportar JSON
ruby cut_optimizer.rb -f exemplo.yml -j

# Desabilitar SVG
ruby cut_optimizer.rb -f exemplo.yml --no-svg

# Desabilitar abertura do navegador
ruby cut_optimizer.rb -f exemplo.yml --no-open

# Ver todas as opções
ruby cut_optimizer.rb --help
```

### Arquivo YAML - Estrutura

```yaml
# Chapas disponíveis
chapas_disponiveis:
  - identificacao: "MDF 15mm"
    largura: 2750  # milímetros
    altura: 1850
    quantidade: 2

# Peças necessárias
pecas_necessarias:
  - identificacao: "Prateleira"
    largura: 900
    altura: 300
    quantidade: 4
```

#### Campos Bilíngues
Você pode usar português ou inglês:
- `chapas_disponiveis` ou `available_sheets`
- `pecas_necessarias` ou `required_pieces`
- `largura` ou `width`
- `altura` ou `height`
- `quantidade` ou `quantity`
- `identificacao` ou `label`

---

## Uso de Arquivos STEP (CAD)

### O que são arquivos STEP?
Arquivos CAD exportados de:
- OnShape
- SolidWorks
- Fusion 360
- FreeCAD
- AutoCAD

### Como Usar

#### 1. Exportar do CAD
No seu software CAD, exporte como `.step` ou `.stp`

#### 2. Converter para YAML
```bash
ruby cut_optimizer.rb -f meu_projeto.step
```

Isso gera `meu_projeto.yml` automaticamente.

#### 3. Editar o YAML
O arquivo gerado contém:
- ✅ Todas as peças detectadas
- ✅ Espessuras identificadas
- ✅ Agrupamento por espessura

**Você só precisa ajustar:**
- Quantidades das peças
- Dimensões das chapas disponíveis
- Quantidade de chapas

#### 4. Executar Otimização
```bash
ruby cut_optimizer.rb -f meu_projeto.yml
```

### Agrupamento Automático
Peças são agrupadas por espessura:
```
📊 Peças agrupadas por espessura:
  • 12mm: 5 peça(s)
  • 15mm: 8 peça(s)
  • 18mm: 3 peça(s)
```

---

## Cortes Lineares (1D)

Para tubos, barras, sarrafos, perfis metálicos.

### Uso CLI

```bash
ruby linear_cut_optimizer.rb -f exemplo_tubos.yml
```

### Arquivo YAML para Lineares

```yaml
barras_disponiveis:
  - identificacao: "Tubo quadrado 50x50"
    comprimento: 6000  # milímetros
    quantidade: 5

pecas_necessarias:
  - identificacao: "Montante vertical"
    comprimento: 2400
    quantidade: 4
  - identificacao: "Travessa horizontal"
    comprimento: 1200
    quantidade: 6
```

### Opções

```bash
# Alterar espessura do corte
ruby linear_cut_optimizer.rb -f tubos.yml -c 4

# Exportar JSON
ruby linear_cut_optimizer.rb -f tubos.yml -j
```

### Resultado
```
=== Barra 1: Tubo quadrado 50x50 ===
Comprimento total: 6000mm
Peças cortadas:
  1. Montante vertical: 2400mm (0-2400mm)
  2. Travessa horizontal: 1200mm (2404-3604mm)
  3. Travessa horizontal: 1200mm (3608-4808mm)

Sobra: 1188mm (aproveitável)
Eficiência: 80.2%
```

---

## Impressão de Resultados

### Versão para Impressão (CLI)

Após executar a otimização:
```bash
firefox output/print.html
# ou
xdg-open output/print.html
```

### O que contém:

**Página 1: Resumo**
- Estatísticas gerais
- Instruções de marcenaria

**Páginas 2+: Uma chapa por página**
- ☐ Checkboxes para marcar peças cortadas
- Tabela com todas as peças
- Coordenadas (X, Y)
- Indicador de rotação (↻)
- Diagrama SVG

### Configurar Impressão
- Tamanho: A4
- Orientação: Retrato
- Margens: Padrão (15mm)
- Cores: Ativadas

### Web App
Na aplicação web, clique em "🖨️ Versão para Impressão" e depois `Ctrl+P` para imprimir diretamente como PDF.

---

## Solução de Problemas

### Erro: Rails não encontrado
```bash
gem install rails --no-document
```

### Erro: Bundle não encontrado
```bash
gem install bundler
```

### Erro: Arquivo STEP não reconhecido
Certifique-se que o arquivo tem extensão `.step` ou `.stp`:
```bash
mv arquivo.STEP arquivo.step
```

### Peças não couberam
**Solução:**
1. Adicione mais chapas no YAML
2. Reduza dimensões das peças
3. Verifique se allow_rotation está ativo

### SVGs não aparecem
```bash
# CLI
ruby cut_optimizer.rb -f exemplo.yml --no-svg  # Desliga SVG
ruby cut_optimizer.rb -f exemplo.yml           # Com SVG (padrão)

# Web
bin/rails tailwindcss:build  # Recompila assets
```

### Navegador não abre automaticamente
```bash
# Desabilitar abertura automática
ruby cut_optimizer.rb -f exemplo.yml --no-open

# Abrir manualmente
firefox output/index.html
```

### Erro no Web App - Assets
```bash
cd web
bin/rails tailwindcss:build
bin/rails assets:precompile
```

### Erro no Web App - Database
```bash
cd web
bin/rails db:drop db:create db:migrate db:seed
```

---

## 📊 Arquivos de Exemplo

### CLI
- `exemplo.yml` - Exemplo básico
- `exemplo_armario.yml` - Armário completo
- `exemplo_caixa.yml` - Caixa simples
- `exemplo_tubos.yml` - Cortes lineares
- `exemplo_sarrafos.yml` - Sarrafos de madeira

### Web App
Dados de exemplo carregados automaticamente com `db:seed`:
- Armário de Cozinha
- Caixa de Armazenamento
- Mesa de Centro

---

## 🎯 Dicas Práticas

### Espessura do Corte
- Serra circular: 3-4mm
- Esquadrejadeira: 2-3mm
- Serra manual: 2mm

### Rotação de Peças
- **Ativar**: Melhor aproveitamento
- **Desativar**: Quando o veio da madeira importa

### Margem de Segurança
Adicione 1-2mm nas dimensões para compensar imperfeições.

### Ordem de Corte
O sistema já ordena peças maiores primeiro automaticamente.

### Identificação Clara
Use nomes descritivos:
- ❌ "Peça 1", "Peça 2"
- ✅ "Lateral direita", "Prateleira superior"

---

## 📞 Links Úteis

- **README Principal**: `README.md`
- **Web App**: `web/README_WEB.md`
- **Documentação Técnica**: `docs/`

---

**Desenvolvido com ❤️ para marceneiros e entusiastas de marcenaria!**

