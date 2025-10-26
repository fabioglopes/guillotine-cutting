# 🪚 Otimizador de Cortes - Aplicação Web Rails

Interface web completa para o otimizador de cortes de madeira e metais.

## 🌟 Funcionalidades

- ✅ **Upload de Arquivos**: Suporte para YAML e STEP
- ✅ **Configuração Manual**: Formulário interativo para criar projetos
- ✅ **Otimização Assíncrona**: Processamento em background
- ✅ **Visualização de Resultados**: SVGs inline e downloads
- ✅ **Histórico de Projetos**: Banco de dados com todos os projetos
- ✅ **Estatísticas**: Eficiência, chapas utilizadas, peças cortadas
- ✅ **Download de Resultados**: HTML para impressão e SVGs individuais

## 📋 Requisitos

- Ruby 3.4+
- Rails 8.1+
- SQLite3 (desenvolvimento) ou PostgreSQL (produção)

## 🚀 Instalação

### 1. Instalar Dependências

```bash
cd web
bundle install
```

### 2. Configurar Banco de Dados

```bash
bin/rails db:create
bin/rails db:migrate
bin/rails db:seed  # Opcional: dados de exemplo
```

### 3. Iniciar Servidor

```bash
bin/dev  # Com Tailwind CSS watch
# ou
bin/rails server  # Apenas Rails
```

Acesse: http://localhost:3000

## 📖 Como Usar

### Criar Novo Projeto

1. Acesse a página inicial
2. Clique em "Novo Projeto"
3. Escolha uma das opções:

#### Opção 1: Upload de Arquivo
- Faça upload de um arquivo YAML ou STEP
- O sistema irá extrair automaticamente as chapas e peças
- Clique em "Criar Projeto"

#### Opção 2: Configuração Manual
- Preencha o nome e descrição do projeto
- Adicione chapas disponíveis (largura, altura, quantidade)
- Adicione peças necessárias (largura, altura, quantidade)
- Clique em "Criar Projeto"

### Processar Otimização

1. Abra o projeto criado
2. Clique em "▶️ Processar Otimização"
3. Aguarde o processamento (alguns segundos)
4. A página será atualizada automaticamente

### Ver Resultados

Após a otimização ser concluída, você verá:

- **Estatísticas**: Chapas utilizadas, peças cortadas, eficiência
- **Visualização**: SVGs com layouts de corte inline
- **Downloads**: 
  - `print.html` - Versão otimizada para impressão
  - `index.html` - Visualização interativa
  - SVGs individuais de cada chapa

### Editar Projeto

1. Abra o projeto
2. Clique em "Editar"
3. Modifique chapas ou peças
4. Salve as alterações
5. Reprocesse a otimização

## 🗂️ Estrutura do Projeto

```
web/
├── app/
│   ├── controllers/
│   │   └── projects_controller.rb    # CRUD de projetos
│   ├── models/
│   │   ├── project.rb                # Model principal
│   │   ├── sheet.rb                  # Chapas
│   │   └── piece.rb                  # Peças
│   ├── services/
│   │   ├── optimizer_service.rb      # Lógica de otimização
│   │   ├── web_report_generator.rb   # Geração de relatórios
│   │   ├── cutting_optimizer.rb      # Motor de otimização
│   │   ├── guillotine_bin_packer.rb  # Algoritmo
│   │   ├── input_loader.rb           # Parser YAML
│   │   ├── step_parser.rb            # Parser STEP
│   │   ├── piece.rb                  # Classe Piece (otimizador)
│   │   └── sheet.rb                  # Classe Sheet (otimizador)
│   ├── jobs/
│   │   └── optimization_job.rb       # Job assíncrono
│   ├── views/
│   │   ├── layouts/
│   │   │   └── application.html.erb  # Layout principal
│   │   └── projects/
│   │       ├── index.html.erb        # Lista de projetos
│   │       ├── new.html.erb          # Criar projeto
│   │       ├── show.html.erb         # Ver projeto
│   │       ├── edit.html.erb         # Editar projeto
│   │       ├── _sheet_fields.html.erb # Partial chapas
│   │       └── _piece_fields.html.erb # Partial peças
│   └── javascript/
│       └── controllers/
│           └── project_form_controller.js  # Stimulus controller
├── db/
│   ├── migrate/                      # Migrations
│   └── seeds.rb                      # Dados de exemplo
└── config/
    └── routes.rb                     # Rotas
```

## 🎨 Tecnologias Utilizadas

- **Backend**: Rails 8.1
- **Frontend**: Tailwind CSS
- **JavaScript**: Stimulus.js + Turbo
- **Banco de Dados**: SQLite3 (dev), PostgreSQL (prod)
- **Jobs**: Active Job (Solid Queue)
- **Storage**: Active Storage

## 🔧 Configuração de Produção

### PostgreSQL

Edite `config/database.yml`:

```yaml
production:
  adapter: postgresql
  database: cut_optimizer_production
  username: <%= ENV['DATABASE_USERNAME'] %>
  password: <%= ENV['DATABASE_PASSWORD'] %>
  host: <%= ENV['DATABASE_HOST'] %>
```

### Variáveis de Ambiente

```bash
export DATABASE_USERNAME=your_username
export DATABASE_PASSWORD=your_password
export DATABASE_HOST=localhost
export RAILS_ENV=production
export SECRET_KEY_BASE=$(rails secret)
```

### Deploy

```bash
bin/rails assets:precompile
bin/rails db:migrate
bin/rails server -e production
```

## 📊 API Endpoints

Embora seja uma aplicação web tradicional, as principais rotas são:

- `GET /` - Lista de projetos
- `GET /projects/new` - Criar novo projeto
- `POST /projects` - Salvar projeto
- `GET /projects/:id` - Ver projeto
- `GET /projects/:id/edit` - Editar projeto
- `PATCH /projects/:id` - Atualizar projeto
- `DELETE /projects/:id` - Deletar projeto
- `POST /projects/:id/optimize` - Processar otimização
- `GET /projects/:id/download/:filename` - Download de arquivo

## 🐛 Troubleshooting

### Erro ao fazer upload

Verifique se Active Storage está configurado:
```bash
bin/rails active_storage:install
bin/rails db:migrate
```

### Otimização não processa

Verifique os logs:
```bash
tail -f log/development.log
```

### Assets não carregam

Compile os assets do Tailwind:
```bash
bin/rails tailwindcss:build
```

## 🤝 Contribuindo

Sugestões e melhorias são bem-vindas!

## 📝 Licença

Software livre para uso pessoal e comercial.

---

Desenvolvido com ❤️ para marceneiros e entusiastas de marcenaria!

