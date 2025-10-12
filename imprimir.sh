#!/bin/bash

# Script para abrir diretamente a versão de impressão

echo "🖨️  Abrindo versão para impressão..."
echo ""

if [ ! -f "output/print.html" ]; then
    echo "❌ Arquivo output/print.html não encontrado!"
    echo ""
    echo "Execute primeiro:"
    echo "  ruby cut_optimizer.rb -f seu_arquivo.yml"
    exit 1
fi

# Tenta abrir o arquivo no navegador
xdg-open output/print.html 2>/dev/null || \
firefox output/print.html 2>/dev/null || \
google-chrome output/print.html 2>/dev/null || \
chromium output/print.html 2>/dev/null || \
{
    echo "❌ Não foi possível abrir o navegador automaticamente"
    echo ""
    echo "Abra manualmente: output/print.html"
    exit 1
}

echo "✅ Versão de impressão aberta no navegador!"
echo ""
echo "📋 Instruções:"
echo "  1. Clique no botão verde '🖨️ IMPRIMIR'"
echo "  2. Configure sua impressora (A4, cores ativadas)"
echo "  3. Imprima ou salve como PDF"
echo ""
echo "💡 Dica: Use as caixas ☐ para marcar peças cortadas na oficina!"

