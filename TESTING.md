# 🧪 Guia de Testes

## 🚀 Comandos Rápidos

```bash
# Todos os testes (CLI + Web)
./run_all_tests.sh

# CLI apenas
ruby test_basic.rb
ruby cut_optimizer.rb -f exemplo.yml

# Web apenas
cd web && bin/rails test
```

## 🔧 Testes por Categoria

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

## 📊 Status

**Total:** 121 testes implementados
- ✅ CLI: Funcionando
- ⚠️ Web: 33/121 passando (conflito de nomes Piece/Sheet entre models e lib)

**Testes Cobertos:**
- Models: Project, Sheet, Piece
- Services: OptimizerService, WebReportGenerator
- Lib: Piece, Sheet, GuillotineBinPacker, CuttingOptimizer, InputLoader
- Integração: Fluxo completo de otimização

---

## 🐛 Debug

```bash
cd web
bin/rails test --verbose    # Detalhes
bin/rails test --backtrace  # Stack trace
tail -f log/test.log         # Logs
```

---

## 📞 Problemas Comuns

```bash
# Database not found
cd web && RAILS_ENV=test bin/rails db:create db:migrate

# Gems faltando
cd web && bundle install

# Verificar estrutura
pwd && ls web/test/
```

