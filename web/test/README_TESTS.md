# Guia de Testes - Cut Tables

Este projeto contém testes tanto para as classes da biblioteca compartilhada (`lib/`) quanto para a aplicação Rails (`web/`).

## 📁 Estrutura de Testes

```
test/
├── lib/                   # Testes para classes da biblioteca (../lib/)
│   ├── piece_test.rb
│   ├── sheet_test.rb
│   ├── guillotine_bin_packer_test.rb
│   ├── cutting_optimizer_test.rb
│   └── input_loader_test.rb
├── models/                # Testes para models do Rails
│   ├── project_test.rb
│   ├── sheet_test.rb     # Model Rails::Sheet
│   └── piece_test.rb     # Model Rails::Piece
├── services/              # Testes para services do Rails
│   ├── optimizer_service_test.rb
│   └── web_report_generator_test.rb
├── integration/           # Testes de integração end-to-end
│   └── optimization_flow_test.rb
└── test_helper.rb         # Configuração base dos testes
```

## ⚠️ Conflito de Namespaces

**Problema**: Existe conflito entre as classes `Piece` e `Sheet` da biblioteca (`lib/`) e os models `Piece` e `Sheet` do Rails.

**Solução Implementada**:
- No `test_helper.rb`, as classes da lib são aliasadas como `LibPiece` e `LibSheet`
- Os models do Rails permanecem como `Piece` e `Sheet`
- Os testes usam os aliases apropriados

## 🧪 Executando os Testes

### Preparar Banco de Dados de Teste

```bash
cd web
RAILS_ENV=test bin/rails db:test:prepare
```

### Rodar Todos os Testes

```bash
bin/rails test
```

### Rodar Testes por Categoria

```bash
# Testes da biblioteca (lib/)
bin/rails test:lib

# Testes de models
bin/rails test:models

# Testes de services
bin/rails test:services

# Testes de integração
bin/rails test:integration
```

### Rodar um Arquivo Específico

```bash
bin/rails test test/models/project_test.rb
```

### Rodar um Teste Específico

```bash
bin/rails test test/models/project_test.rb:8
```

## 📝 Cobertura de Testes

### Classes da Biblioteca (`lib/`)

- ✅ **Piece**: Criação, rotação, cálculo de área
- ✅ **Sheet**: Criação, adição de peças, eficiência
- ✅ **GuillotineBinPacker**: Inserção de peças, rotação, cutting width
- ✅ **CuttingOptimizer**: Otimização completa, expansão de peças
- ✅ **InputLoader**: Carregamento de YAML, validação

### Models do Rails

- ✅ **Project**: Validações, associações, status
- ✅ **Sheet** (Rails): Validações, relacionamento com Project
- ✅ **Piece** (Rails): Validações, relacionamento com Project

### Services

- ✅ **OptimizerService**: Orquestração da otimização
- ✅ **WebReportGenerator**: Geração de SVG/HTML

### Integração

- ✅ Fluxo completo: Criação → Otimização → Resultados
- ✅ Diferentes configurações (com/sem rotação, cutting width)
- ✅ Cenários edge cases (muitas peças pequenas, etc.)

## 🐛 Troubleshooting

### Erro de Namespace

Se você ver erros como `wrong number of arguments` ao criar `Piece` ou `Sheet`:

**Problema**: O teste está usando o model do Rails ao invés da classe da lib.

**Solução**: Use `LibPiece` e `LibSheet` nos testes de `test/lib/`.

### Testes de Services Falhando

Se os services não encontrarem as classes da lib:

```ruby
# Verifique se está usando :: para referenciar classes globais:
sheets = [::Sheet.new(...)]  # Classe da lib
pieces = [::Piece.new(...)]   # Classe da lib
```

### Banco de Dados Não Preparado

```bash
# Limpar e recriar banco de teste
RAILS_ENV=test bin/rails db:drop db:create db:migrate
```

## 📚 Escrevendo Novos Testes

### Teste para Classe da Lib

```ruby
require "test_helper"

class NewLibClassTest < ActiveSupport::TestCase
  test "description" do
    # Use LibPiece e LibSheet para classes da lib
    obj = LibPiece.new("P1", 100, 200, 1)
    assert_equal 100, obj.width
  end
end
```

### Teste para Model do Rails

```ruby
require "test_helper"

class NewModelTest < ActiveSupport::TestCase
  test "description" do
    # Use Piece e Sheet normalmente (models do Rails)
    project = Project.create!(name: "Test", cutting_width: 3)
    piece = project.pieces.create!(label: "Test", width: 100, height: 200)
    assert piece.persisted?
    project.destroy
  end
end
```

### Teste de Service

```ruby
require "test_helper"

class NewServiceTest < ActiveSupport::TestCase
  test "description" do
    project = Project.create!(name: "Test", cutting_width: 3)
    # ... configuração ...
    
    service = MyService.new(project)
    result = service.perform
    
    assert_not_nil result
    project.destroy
  end
end
```

## 🎯 Métricas de Sucesso

Execute os testes e verifique:

- ✅ Todos os testes passando (0 failures, 0 errors)
- ✅ Cobertura adequada de casos de uso
- ✅ Testes executam em tempo razoável (< 30s total)

## 🚀 CI/CD

Para integração contínua, adicione ao seu pipeline:

```yaml
test:
  script:
    - cd web
    - bundle install
    - RAILS_ENV=test bin/rails db:test:prepare
    - bin/rails test
```

## 📖 Documentação Adicional

- [Minitest Documentation](https://github.com/minitest/minitest)
- [Rails Testing Guide](https://guides.rubyonrails.org/testing.html)

