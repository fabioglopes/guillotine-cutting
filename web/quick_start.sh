#!/bin/bash

echo "🪚 Otimizador de Cortes - Início Rápido"
echo "========================================"
echo ""

# Verificar se está na pasta correta
if [ ! -f "bin/rails" ]; then
  echo "❌ Erro: Execute este script da pasta web/"
  exit 1
fi

# Verificar se Ruby está instalado
if ! command -v ruby &> /dev/null; then
  echo "❌ Ruby não encontrado. Instale Ruby 3.4+"
  exit 1
fi

echo "✅ Ruby $(ruby --version)"

# Verificar se bundler está instalado
if ! command -v bundle &> /dev/null; then
  echo "📦 Instalando Bundler..."
  gem install bundler
fi

# Instalar dependências
echo ""
echo "📦 Instalando dependências..."
bundle install --quiet

# Configurar banco de dados
if [ ! -f "db/development.sqlite3" ]; then
  echo ""
  echo "🗄️ Criando banco de dados..."
  bin/rails db:create
  bin/rails db:migrate
  
  echo ""
  read -p "Deseja carregar dados de exemplo? (s/N): " -n 1 -r
  echo
  if [[ $REPLY =~ ^[SsYy]$ ]]; then
    bin/rails db:seed
  fi
else
  echo ""
  echo "✅ Banco de dados já existe"
fi

# Compilar assets
echo ""
echo "🎨 Compilando assets do Tailwind CSS..."
bin/rails tailwindcss:build

# Iniciar servidor
echo ""
echo "🚀 Iniciando servidor Rails..."
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Acesse: http://localhost:3000"
echo "  Pressione Ctrl+C para parar o servidor"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Usar bin/dev se disponível (com Tailwind watch), senão usar bin/rails server
if [ -f "bin/dev" ]; then
  bin/dev
else
  bin/rails server
fi

