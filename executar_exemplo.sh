#!/bin/bash

# Script rápido para executar a otimização do seu arquivo caixa.yml

echo "🪚 Executando Otimizador de Cortes com caixa.yml..."
echo ""

ruby cut_optimizer.rb -f caixa.yml

echo ""
echo "=========================================="
echo "✅ Pronto!"
echo ""
echo "O navegador deve abrir automaticamente com os layouts."
echo ""
echo "Se não abrir automaticamente:"
echo "  firefox output/index.html"
echo "  ou"
echo "  xdg-open output/index.html"
echo "=========================================="

