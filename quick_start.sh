#!/bin/bash

# Script de início rápido para o Otimizador de Cortes

echo "=========================================="
echo "   Otimizador de Cortes de Madeira"
echo "=========================================="
echo ""

# Verifica se Ruby está instalado
if ! command -v ruby &> /dev/null; then
    echo "❌ Ruby não está instalado!"
    echo ""
    echo "Por favor, instale Ruby primeiro:"
    echo ""
    echo "Ubuntu/Debian:"
    echo "  sudo apt update && sudo apt install ruby-full"
    echo ""
    echo "Fedora:"
    echo "  sudo dnf install ruby"
    echo ""
    echo "Arch Linux:"
    echo "  sudo pacman -S ruby"
    echo ""
    echo "Para mais informações, veja INSTALACAO.md"
    exit 1
fi

echo "✓ Ruby detectado: $(ruby --version)"
echo ""

# Menu
echo "Escolha uma opção:"
echo "1. Executar teste básico"
echo "2. Executar exemplo completo"
echo "3. Executar exemplo simples"
echo "4. Modo interativo"
echo "5. Gerar relatórios visuais (SVG + JSON)"
echo ""
read -p "Opção [1-5]: " opcao

case $opcao in
    1)
        echo ""
        echo "Executando teste básico..."
        ruby test_basic.rb
        ;;
    2)
        echo ""
        echo "Executando exemplo completo..."
        ruby cut_optimizer.rb -f exemplo.yml
        ;;
    3)
        echo ""
        echo "Executando exemplo simples..."
        ruby cut_optimizer.rb -f exemplo_simples.yml
        ;;
    4)
        echo ""
        echo "Iniciando modo interativo..."
        ruby cut_optimizer.rb -i
        ;;
    5)
        echo ""
        echo "Gerando relatórios visuais..."
        ruby cut_optimizer.rb -f exemplo.yml -s -j
        echo ""
        echo "✓ Relatórios gerados!"
        echo "  - JSON: cutting_report.json"
        echo "  - SVG: output/sheet_*.svg"
        echo ""
        echo "Abra os arquivos SVG no seu navegador para visualizar os layouts."
        ;;
    *)
        echo "Opção inválida!"
        exit 1
        ;;
esac

echo ""
echo "=========================================="
echo "Para mais opções, use: ruby cut_optimizer.rb --help"
echo "=========================================="

