# 📦 Guia de Instalação

## Instalando Ruby

Este software requer Ruby 2.7 ou superior. Aqui estão as instruções para diferentes sistemas operacionais:

### Debian/Ubuntu/Linux Mint

```bash
sudo apt update
sudo apt install ruby-full
```

### Fedora/RHEL/CentOS

```bash
sudo dnf install ruby
```

### Arch Linux

```bash
sudo pacman -S ruby
```

### macOS

Ruby já vem pré-instalado no macOS. Para uma versão mais recente, use Homebrew:

```bash
brew install ruby
```

### Windows

Baixe e instale o RubyInstaller: https://rubyinstaller.org/

## Verificando a Instalação

Após instalar, verifique se o Ruby está funcionando:

```bash
ruby --version
```

Você deve ver algo como: `ruby 3.1.2p20 (2022-04-12 revision 4491bb740a) [x86_64-linux]`

## Testando o Software

1. Navegue até o diretório do projeto:
```bash
cd /home/fabio/software-projects/cut-tables
```

2. Execute o exemplo:
```bash
ruby cut_optimizer.rb -f exemplo.yml
```

3. Para gerar relatórios visuais:
```bash
ruby cut_optimizer.rb -f exemplo.yml -s -j
```

4. Para modo interativo:
```bash
ruby cut_optimizer.rb -i
```

## Solução de Problemas

### Erro: "cannot load such file"

Se você receber erros sobre arquivos não encontrados, certifique-se de estar no diretório correto:
```bash
cd /home/fabio/software-projects/cut-tables
```

### Erro: "command not found: ruby"

Ruby não está instalado ou não está no PATH. Siga as instruções de instalação acima.

### Permissões

Se necessário, torne o script executável:
```bash
chmod +x cut_optimizer.rb
```

Então você pode executá-lo diretamente:
```bash
./cut_optimizer.rb -f exemplo.yml
```

