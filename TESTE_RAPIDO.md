# 🧪 Teste Rápido

Quer testar rapidamente o otimizador? Siga estes passos:

## Passo 1: Certifique-se que Ruby está instalado

```bash
ruby --version
```

Se não tiver Ruby instalado, veja `INSTALACAO.md`.

## Passo 2: Execute um exemplo

### Opção A: Script automático
```bash
./executar_exemplo.sh
```

### Opção B: Comando direto
```bash
ruby cut_optimizer.rb -f caixa.yml
```

## O que vai acontecer?

1. ⚙️ O programa otimiza os cortes
2. 📊 Mostra relatório no terminal
3. 🎨 Gera SVGs em `output/`
4. 🌐 **Abre o navegador automaticamente** com os layouts

## Resultado Esperado

Você verá no terminal:
```
=== Iniciando otimização de cortes ===
...
--- GERANDO LAYOUTS SVG ---
  ✓ Chapa MDF 10mm #1: output/sheet_1.svg
  ✓ Chapa Compensado #1: output/sheet_2.svg
  ✓ Índice HTML: output/index.html

🌐 Abrindo navegador com os layouts...

✓ Otimização concluída!
```

E o **navegador abrirá automaticamente** mostrando uma página bonita com todos os layouts visuais! 🎉

## Se o navegador não abrir

Isso é raro, mas se acontecer:

```bash
# Linux
xdg-open output/index.html
# ou
firefox output/index.html

# macOS
open output/index.html

# Windows
start output/index.html
```

## Próximos Passos

1. **Experimente com seus próprios dados**
   - Copie `caixa.yml` para `meu_projeto.yml`
   - Edite com suas medidas
   - Execute: `ruby cut_optimizer.rb -f meu_projeto.yml`

2. **Explore as opções**
   ```bash
   ruby cut_optimizer.rb --help
   ```

3. **Modo interativo** (sem precisar criar arquivo YAML)
   ```bash
   ruby cut_optimizer.rb -i
   ```

## Desabilitando Funcionalidades (opcional)

```bash
# Não abrir navegador automaticamente
ruby cut_optimizer.rb -f caixa.yml --no-open

# Não gerar SVGs
ruby cut_optimizer.rb -f caixa.yml --no-svg

# Não rotacionar peças
ruby cut_optimizer.rb -f caixa.yml --no-rotation
```

---

**Tudo funcionando? Ótimo! Agora use com seus projetos reais de marcenaria!** 🪚✨

