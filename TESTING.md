# 🧪 Guia de Testes

Este documento descreve como executar todos os testes do projeto Cut Tables.

## 📋 Estrutura de Testes

O projeto possui testes para duas partes principais:

### 1️⃣ **CLI (Linha de Comando)**
- Testes manuais com arquivos YAML
- Script de teste básico automatizado
- Localização: `/test_basic.rb`

### 2️⃣ **Web (Rails)**
- Testes unitários (Models, Services, Lib)
- Testes de integração
- Localização: `/web/test/`

---

## 🚀 Comandos Rápidos

### ⚡ Rodar TODOS os Testes (Recomendado)

```bash
./run_all_tests.sh
```

Esse script executa:
1. Teste básico do CLI
2. Teste completo do CLI com arquivo YAML
3. Todos os testes do Rails

---

## 🔧 Testes Individuais

### CLI - Linha de Comando

#### Teste Básico Automatizado
```bash
ruby test_basic.rb
```

#### Teste Manual com Arquivo YAML
```bash
ruby cut_optimizer.rb -f exemplo.yml
```

#### Teste com Arquivo Armário
```bash
ruby cut_optimizer.rb -f exemplo_armario.yml
```

#### Teste Modo Interativo
```bash
ruby cut_optimizer.rb -i
```

---

### Web - Aplicação Rails

#### Preparar Banco de Dados de Teste
```bash
cd web
RAILS_ENV=test bin/rails db:test:prepare
```

#### Todos os Testes
```bash
cd web
bin/rails test
```

#### Testes por Categoria

**Models (Project, Sheet, Piece)**
```bash
cd web
bin/rails test:models
```

**Services (OptimizerService, WebReportGenerator)**
```bash
cd web
bin/rails test:services
```

**Lib (Classes compartilhadas: Piece, Sheet, CuttingOptimizer, etc.)**
```bash
cd web
bin/rails test:lib
```

**Integração (Fluxo completo end-to-end)**
```bash
cd web
bin/rails test:integration
```

#### Teste Específico
```bash
cd web
bin/rails test test/models/project_test.rb
bin/rails test test/services/optimizer_service_test.rb:10  # Linha específica
```

---

## 📊 Cobertura de Testes

### ✅ Testes Implementados

#### **Lib (Biblioteca Core)**
- ✅ `Piece` - Representação de peças
- ✅ `Sheet` - Representação de chapas
- ✅ `GuillotineBinPacker` - Algoritmo de empacotamento
- ✅ `CuttingOptimizer` - Otimizador principal
- ✅ `InputLoader` - Carregamento de arquivos YAML

#### **Models (Rails)**
- ✅ `Project` - Projetos de corte
- ✅ `Sheet` (Model) - Chapas no banco de dados
- ✅ `Piece` (Model) - Peças no banco de dados

#### **Services (Rails)**
- ✅ `OptimizerService` - Ponte entre Rails e Otimizador
- ✅ `WebReportGenerator` - Geração de relatórios HTML/SVG

#### **Integração**
- ✅ Fluxo completo: Criação → Otimização → Resultados
- ✅ Teste com rotação desabilitada
- ✅ Teste com espessura de corte grande
- ✅ Teste com muitas peças pequenas
- ✅ Ciclo de vida completo do projeto

### ⚠️ Testes Não Implementados (Sugestões)

#### **Lib**
- ⏳ `StepParser` - Parser de arquivos STEP
- ⏳ `LinearOptimizer` - Otimização linear
- ⏳ `LinearReportGenerator` - Relatórios lineares
- ⏳ `ReportGenerator` - Gerador de relatórios CLI

#### **Controllers (Rails)**
- ⏳ `ProjectsController` - CRUD e otimização
- ⏳ Testes de requisições HTTP
- ⏳ Testes de upload de arquivos
- ⏳ Testes de download de resultados

#### **Jobs (Rails)**
- ⏳ `OptimizationJob` - Processamento em background
- ⏳ Tratamento de erros em jobs

#### **Validações**
- ⏳ Validações complexas de dimensões
- ⏳ Conflitos de unidades (mm, cm, etc.)
- ⏳ Limites de tamanho de arquivo

#### **Performance**
- ⏳ Teste com 1000+ peças
- ⏳ Teste com 100+ chapas
- ⏳ Benchmarks de otimização

#### **Edge Cases**
- ⏳ Peças que não cabem em nenhuma chapa
- ⏳ Chapas menores que espessura de corte
- ⏳ Dimensões zero ou negativas
- ⏳ Arquivos YAML malformados
- ⏳ Arquivos STEP inválidos

---

## 🐛 Debugging

### Ver Logs de Teste
```bash
cd web
tail -f log/test.log
```

### Executar Teste com Verbose
```bash
cd web
bin/rails test --verbose
```

### Executar Teste em Modo Debug
```bash
cd web
bin/rails test --backtrace
```

### Verificar Fixtures
```bash
cd web
ls test/fixtures/
```

---

## 📈 Estatísticas Atuais

```
CLI:
  ✅ 1 teste básico automatizado
  ✅ 2 arquivos YAML de exemplo

Web (Rails):
  ✅ 121 testes implementados
  ├── Models: ~30 testes
  ├── Services: ~40 testes
  ├── Lib: ~45 testes
  └── Integration: ~6 testes
```

---

## 🔄 CI/CD (Futuro)

Para integração contínua, considere adicionar:

```yaml
# .github/workflows/test.yml
name: Tests
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: ruby/setup-ruby@v1
        with:
          ruby-version: 3.4
      - run: bundle install
      - run: ./run_all_tests.sh
```

---

## 💡 Dicas

1. **Rode os testes frequentemente** durante o desenvolvimento
2. **Sempre rode `./run_all_tests.sh`** antes de commits importantes
3. **Adicione testes** quando encontrar bugs
4. **Mantenha testes rápidos** - use fixtures ao invés de criar muitos dados
5. **Use mocks/stubs** para serviços externos se necessário

---

## 📞 Troubleshooting

### Erro: "Database not found"
```bash
cd web
RAILS_ENV=test bin/rails db:create db:migrate
```

### Erro: "Gem not found"
```bash
cd web
bundle install
```

### Erro: "Test files not found"
Verifique se está no diretório correto:
```bash
pwd  # Deve estar em cut-tables/
ls web/test/  # Deve listar os arquivos de teste
```

---

## 🎯 Próximos Passos

1. Implementar testes para `StepParser`
2. Adicionar testes de controller
3. Implementar testes de performance
4. Configurar CI/CD no GitHub Actions
5. Adicionar cobertura de código (SimpleCov)

