# 🚀 Início Rápido

## Passo 1: Instalar Ruby

```bash
# Ubuntu/Debian
sudo apt update && sudo apt install ruby-full

# Fedora
sudo dnf install ruby

# Arch Linux
sudo pacman -S ruby
```

## Passo 2: Testar o Software

```bash
cd /home/fabio/software-projects/cut-tables

# Usar o script de início rápido (recomendado)
./quick_start.sh

# OU executar diretamente
ruby test_basic.rb
```

## Passo 3: Usar com Seus Projetos

### Método 1: Arquivo YAML (Recomendado)

1. Copie um dos exemplos:
```bash
cp exemplo.yml meu_projeto.yml
```

2. Edite `meu_projeto.yml` com suas medidas:
```yaml
chapas_disponiveis:
  - identificacao: "MDF 15mm"
    largura: 2750  # em mm
    altura: 1850
    quantidade: 2

pecas_necessarias:
  - identificacao: "Prateleira"
    largura: 900
    altura: 300
    quantidade: 4
```

3. Execute:
```bash
ruby cut_optimizer.rb -f meu_projeto.yml
```

### Método 2: Modo Interativo

```bash
ruby cut_optimizer.rb -i
```

O programa vai te guiar passo a passo.

## Opções Úteis

```bash
# Gerar visualizações SVG (abrir no navegador)
ruby cut_optimizer.rb -f exemplo.yml -s

# Exportar relatório JSON
ruby cut_optimizer.rb -f exemplo.yml -j

# Desabilitar rotação de peças
ruby cut_optimizer.rb -f exemplo.yml --no-rotation

# Ajustar espessura do corte (padrão: 3mm)
ruby cut_optimizer.rb -f exemplo.yml -c 4

# Combinar opções
ruby cut_optimizer.rb -f exemplo.yml -s -j -c 3
```

## Exemplos Prontos

- `exemplo_simples.yml` - Teste básico com poucas peças
- `exemplo.yml` - Projeto médio com peças variadas
- `exemplo_armario.yml` - Projeto real de armário de cozinha

## Dicas

1. **Medidas em milímetros**: Todas as medidas devem estar em mm
2. **Espessura do corte**: Ajuste conforme sua serra (circular: 3-4mm)
3. **Rotação**: Deixe ativada para melhor aproveitamento
4. **Margem de segurança**: Adicione 1-2mm nas peças para compensar erros
5. **Visualização**: Use `-s` para gerar SVG e visualizar no navegador

## Ver Relatório Detalhado

Após a otimização, você verá:
- Quantas chapas foram usadas
- Eficiência de aproveitamento (%)
- Posição exata de cada peça (coordenadas X, Y)
- Peças que foram rotacionadas
- Layout ASCII simplificado de cada chapa

## Ajuda

```bash
ruby cut_optimizer.rb --help
```

## Problemas?

Veja `INSTALACAO.md` para guia detalhado de instalação e solução de problemas.

---

**Pronto para otimizar seus cortes!** 🪚


