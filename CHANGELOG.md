# Changelog

## [2.2.0] - 2025-10-12

### 🎨 Melhorias no Layout Visual

#### Corrigido
- **Layout vertical** - Chapas agora aparecem uma embaixo da outra (melhor para visualização)
- **Alinhamento dos cortes** - Peças agora estão perfeitamente alinhadas com as chapas
- **Responsividade** - Cards ocupam toda a largura disponível

#### Melhorado
- Remoção do efeito hover de movimento vertical (mantido apenas o efeito de sombra)
- Melhor suporte para impressão com `page-break-inside: avoid`

---

## [2.1.0] - 2025-10-12

### 🚀 Abertura Automática do Navegador

#### Adicionado
- **Navegador abre automaticamente** com os layouts após otimização
- Nova opção `--[no-]open` para controlar abertura do navegador
- Suporte multi-plataforma (Linux, macOS, Windows)
- Detecta e usa o navegador padrão do sistema
- Fallback para navegadores comuns se o padrão falhar

#### Como Funciona
- No Linux: tenta `xdg-open`, `sensible-browser`, `firefox`, `chrome`, `chromium`
- No macOS: usa `open`
- No Windows: usa `start`

---

## [2.0.0] - 2025-10-12

### 🎨 Melhorias Visuais Principais

#### Adicionado
- **SVGs gerados por padrão** - Não precisa mais usar `-s`
- **Página HTML interativa** (`output/index.html`) com todos os layouts
- **Legendas detalhadas** em cada SVG com informações completas
- **Grid de fundo** nos SVGs para melhor referência visual
- **15 cores distintas** para identificar peças facilmente
- **Cotas dimensionais** mostrando largura e altura das chapas
- **Indicadores de rotação** (↻) para peças rotacionadas
- **Hover effects** interativos nas peças
- **Design responsivo** que se adapta a qualquer tela
- **Modo de impressão** otimizado para levar à oficina
- **Estatísticas visuais** em cada layout (área utilizada/desperdiçada)
- **Botões de download** para cada SVG individual
- **Escala automática** que ajusta o tamanho ideal do layout

#### Melhorado
- **Qualidade visual dos SVGs** - Layout profissional
- **Legibilidade** - Fontes maiores e mais claras
- **Organização** - Informações estruturadas logicamente
- **Performance** - Geração mais rápida de relatórios
- **Documentação** - Adicionado `SVG_FEATURES.md`

#### Modificado
- Opção `-s` agora é `--[no-]svg` (padrão: habilitado)
- SVGs têm escala dinâmica baseada no tamanho da chapa
- Layout de página única com todos os outputs

### 📄 Documentação

#### Adicionado
- `SVG_FEATURES.md` - Guia completo dos recursos visuais
- `executar_exemplo.sh` - Script rápido para teste
- `CHANGELOG.md` - Este arquivo

#### Atualizado
- `README.md` - Novas instruções e exemplos
- `INICIO_RAPIDO.md` - Instruções sobre SVGs

---

## [1.0.0] - 2025-10-11

### Lançamento Inicial

#### Funcionalidades
- Algoritmo Guillotine Bin Packing para otimização
- Suporte a rotação de peças
- Consideração da espessura do corte
- Modo arquivo YAML
- Modo interativo
- Relatórios em console
- Exportação JSON
- Exportação SVG básica
- Classes modulares (Piece, Sheet, Optimizer)
- Documentação completa

#### Arquivos de Exemplo
- `exemplo.yml` - Projeto médio
- `exemplo_simples.yml` - Teste básico
- `exemplo_armario.yml` - Projeto real

#### Documentação
- `README.md` - Documentação principal
- `INSTALACAO.md` - Guia de instalação
- `ALGORITMO.md` - Explicação técnica
- `INICIO_RAPIDO.md` - Quick start guide

---

### Legenda
- 🎨 Interface/Visual
- 🔧 Funcionalidade
- 📄 Documentação
- 🐛 Correção de bugs
- ⚡ Performance
- 🔒 Segurança

