# 🪚 Otimizador de Cortes para Madeira e Metais

Software completo em Ruby para otimizar cortes de materiais, ideal para marcenaria, serralheria e construção.

## 🌐 Duas Formas de Usar

### 🖥️ **Aplicação Web (Recomendado)**
Interface web moderna com Rails:
- Upload de arquivos YAML/STEP (CAD)
- Formulário interativo
- Histórico de projetos
- Visualização inline de resultados

**[📖 Ver guia da aplicação web](web/README_WEB.md)**

```bash
cd web
./quick_start.sh
# Acesse: http://localhost:3000
```

### ⌨️ **Linha de Comando (CLI)**
Script Ruby direto no terminal:
- Rápido e leve
- Sem dependências extras

```bash
ruby cut_optimizer.rb -f exemplo.yml
```

---

## 📦 Dois Otimizadores Incluídos

### 1️⃣ Otimizador 2D - Chapas e Placas
Para materiais com 2 dimensões (largura × altura):
- Chapas de MDF, compensado, OSB
- Placas metálicas
- Vidros e acrílico

### 2️⃣ Otimizador 1D - Tubos e Barras
Para materiais com 1 dimensão (comprimento):
- Tubos quadrados/redondos
- Barras de aço/alumínio
- Sarrafos e ripas de madeira

---

## ✨ Principais Características

- ✅ **Importação de arquivos CAD (STEP)** - OnShape, SolidWorks, Fusion 360
- ✅ **Otimização automática** - Algoritmo Guillotine Bin Packing
- ✅ **Relatórios visuais em SVG** - Layouts coloridos e detalhados
- ✅ **Versão para impressão** - Formato A4 com checkboxes
- ✅ **Suporte bilíngue** - Português e Inglês
- ✅ **Interface web** - Gestão completa de projetos
- ✅ **Rotação de peças** - Opcional para melhor aproveitamento

---

## 🚀 Início Rápido

### Aplicação Web
```bash
cd web
./quick_start.sh
```

### CLI - Arquivo YAML
```bash
ruby cut_optimizer.rb -f exemplo.yml
```

### CLI - Arquivo STEP (CAD)
```bash
# Converte STEP para YAML
ruby cut_optimizer.rb -f projeto.step

# Edita o YAML e executa
ruby cut_optimizer.rb -f projeto.yml
```

### CLI - Cortes Lineares
```bash
ruby linear_cut_optimizer.rb -f exemplo_tubos.yml
```

---

## 📚 Documentação

- **[📖 Guia Completo](GUIA_COMPLETO.md)** - Todas as instruções de uso
- **[🌐 Guia Web App](web/README_WEB.md)** - Aplicação Rails
- **[📁 Documentação Técnica](docs/)** - Detalhes de implementação

---

## 📋 Exemplo de Arquivo YAML

```yaml
# Chapas disponíveis
chapas_disponiveis:
  - identificacao: "MDF 15mm"
    largura: 2750
    altura: 1850
    quantidade: 2

# Peças necessárias
pecas_necessarias:
  - identificacao: "Prateleira"
    largura: 900
    altura: 300
    quantidade: 4
  - identificacao: "Lateral"
    largura: 1800
    altura: 400
    quantidade: 2
```

---

## 📊 Resultados Gerados

### CLI
- **console** - Relatório detalhado em texto
- **output/index.html** - Visualização interativa
- **output/print.html** - Versão para impressão A4
- **output/sheet_*.svg** - Layouts individuais
- **JSON** - Dados estruturados (opcional)

### Web App
- Visualização inline no navegador
- Downloads de HTMLs e SVGs
- Histórico persistente no banco

---

## 🎯 Exemplos Incluídos

- `exemplo.yml` - Exemplo básico
- `exemplo_armario.yml` - Armário completo
- `exemplo_caixa.yml` - Caixa simples
- `exemplo_tubos.yml` - Cortes lineares
- `Part Studio 1.step` - Exemplo CAD

---

## 💡 Dicas

1. **Use arquivos CAD**: Exporte STEP e converta automaticamente
2. **Espessura do corte**: Ajuste conforme sua serra (padrão: 3mm)
3. **Rotação**: Mantenha ativada para melhor aproveitamento
4. **Impressão**: Use `print.html` para levar à oficina

---

## 🔧 Estrutura do Projeto

```
cut-tables/
├── cut_optimizer.rb           # CLI - Otimizador 2D
├── linear_cut_optimizer.rb    # CLI - Otimizador 1D
├── lib/                       # Biblioteca principal
├── web/                       # Aplicação Rails
├── output/                    # Resultados gerados (CLI)
├── exemplo*.yml               # Arquivos de exemplo
├── GUIA_COMPLETO.md          # Guia consolidado
└── docs/                      # Documentação técnica
```

---

## 📞 Suporte

Problemas? Consulte o [**Guia Completo**](GUIA_COMPLETO.md) seção "Solução de Problemas".

---

## 📝 Licença

Software livre para uso pessoal e comercial.

---

**Desenvolvido com ❤️ para marceneiros e entusiastas de marcenaria!**
