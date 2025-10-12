#!/bin/bash
# Script para converter arquivos STEP em YAML

echo "╔══════════════════════════════════════════════════════════════╗"
echo "║   🔄 Conversor STEP → YAML                                  ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""

if [ -z "$1" ]; then
    echo "❌ Por favor, forneça um arquivo STEP"
    echo ""
    echo "Uso: ./converter_step.sh arquivo.step [saida.yml]"
    echo ""
    echo "Exemplos:"
    echo "  ./converter_step.sh 'projeto.step'"
    echo "  ./converter_step.sh 'projeto.step' config_projeto.yml"
    echo ""
    exit 1
fi

STEP_FILE="$1"
OUTPUT_FILE="${2:-}"

# Check if file exists
if [ ! -f "$STEP_FILE" ]; then
    echo "❌ Arquivo não encontrado: $STEP_FILE"
    exit 1
fi

echo "📐 Convertendo: $STEP_FILE"
echo ""

# Build command
if [ -n "$OUTPUT_FILE" ]; then
    CMD="ruby cut_optimizer.rb -f '$STEP_FILE' --convert-to-yaml '$OUTPUT_FILE'"
else
    CMD="ruby cut_optimizer.rb -f '$STEP_FILE' --convert-to-yaml"
fi

# Execute conversion
eval "$CMD"

if [ $? -eq 0 ]; then
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "✨ Conversão concluída!"
    echo ""
    if [ -n "$OUTPUT_FILE" ]; then
        YAML_FILE="$OUTPUT_FILE"
    else
        YAML_FILE=$(echo "$STEP_FILE" | sed 's/\.\(step\|stp\)$/.yml/i')
    fi
    echo "💡 Agora você pode:"
    echo "   • Editar: nano '$YAML_FILE'"
    echo "   • Otimizar: ruby cut_optimizer.rb -f '$YAML_FILE'"
else
    echo ""
    echo "❌ Erro durante a conversão"
fi

