#!/bin/bash

# Script para rodar todos os testes (CLI + Web)

set -e  # Exit on error

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🧪 EXECUTANDO TODOS OS TESTES"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Contadores
TESTS_PASSED=0
TESTS_FAILED=0

echo "📦 1/3: Testando Biblioteca Core (lib/)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if ruby test_basic.rb; then
    echo -e "${GREEN}✅ CLI básico funcionando${NC}"
    ((TESTS_PASSED++))
else
    echo -e "${RED}❌ CLI básico falhou${NC}"
    ((TESTS_FAILED++))
fi
echo ""

echo "🖥️  2/3: Testando CLI completo"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if ruby cut_optimizer.rb -f exemplo.yml > /dev/null 2>&1; then
    echo -e "${GREEN}✅ CLI completo funcionando${NC}"
    ((TESTS_PASSED++))
else
    echo -e "${RED}❌ CLI completo falhou${NC}"
    ((TESTS_FAILED++))
fi
echo ""

echo "🌐 3/3: Testando Aplicação Web (Rails)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
cd web

# Preparar banco de dados de teste
echo "Preparando banco de dados de teste..."
RAILS_ENV=test bin/rails db:test:prepare > /dev/null 2>&1

# Rodar testes
echo ""
echo "🧪 Rodando testes do Rails..."
echo ""

if bin/rails test 2>&1 | tee /tmp/rails_test_output.txt | tail -20; then
    echo -e "${GREEN}✅ Testes Rails passaram${NC}"
    ((TESTS_PASSED++))
else
    echo -e "${YELLOW}⚠️  Alguns testes Rails falharam (veja detalhes acima)${NC}"
    ((TESTS_FAILED++))
fi

cd ..

# Resumo
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 RESUMO DOS TESTES"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo -e "✅ Passaram: ${GREEN}${TESTS_PASSED}${NC}"
echo -e "❌ Falharam: ${RED}${TESTS_FAILED}${NC}"
echo ""

if [ $TESTS_FAILED -eq 0 ]; then
    echo -e "${GREEN}🎉 TODOS OS TESTES PASSARAM!${NC}"
    exit 0
else
    echo -e "${YELLOW}⚠️  Alguns testes falharam. Veja os detalhes acima.${NC}"
    exit 1
fi

