# Emacs 31 do zero (Fedora + XFCE)

Configuração equivalente à do Doom Emacs: Evil, Vertico, Corfu, Magit, Eglot,
tree-sitter, Astro e doom-themes.

Arquivos:

- `early-init.el`: ajustes antes da interface carregar.
- `init.el`: toda a configuração.

## Como testar sem mexer no Doom

O Doom fica em `~/.config/emacs`. **Não copie estes arquivos para lá.** Use uma
pasta separada e diga ao Emacs para usá-la com `--init-directory`:

```bash
mkdir ~/emacs-vanilla
cp early-init.el init.el ~/emacs-vanilla/
emacs --init-directory ~/emacs-vanilla
```

Para abrir o Doom, rode `emacs` normalmente. Os dois não se misturam: os
pacotes, o cache e os arquivos de dados da versão nova ficam dentro de
`~/emacs-vanilla`.

Atalho opcional no `~/.bashrc`:

```bash
alias emacs-v='emacs --init-directory ~/emacs-vanilla'
```

## Antes de abrir

Instale as dependências:

```bash
sudo dnf install git ripgrep fd-find gcc gcc-c++ make nodejs npm
```

Instale a fonte **JetBrains Mono**:

```bash
sudo dnf install jetbrains-mono-fonts
```

Os ícones usam outra fonte, que o próprio Emacs instala no passo 2 da primeira
abertura (`M-x nerd-icons-install-fonts`).

Instale os language servers com o script que acompanha estes arquivos:

```bash
./instalar-language-servers.sh
```

## Primeira abertura

1. **Espere os pacotes baixarem.** Na primeira vez o Emacs instala tudo
   sozinho e demora alguns minutos. Pode aparecer uma janela de avisos de
   compilação, que é normal. Quando terminar, **feche e abra o Emacs de novo**.
2. **Instale os ícones:** `M-x nerd-icons-install-fonts`. Depois reinicie o
   Emacs para a modeline e o dashboard mostrarem os ícones.
3. **Instale as grammars tree-sitter:** `M-x my/treesit-install-grammars`.
   Cada grammar é baixada e compilada, então demora um pouco.
4. **No projeto Astro**, rode:

   ```bash
   npm i -D typescript@6 prettier-plugin-astro
   ```

   O `astro-ls` precisa do TypeScript do projeto, e a formatação ao salvar
   precisa do plugin do Prettier declarado em `plugins` no `.prettierrc`.
5. **Abra um arquivo `.astro`.** O Eglot deve iniciar o servidor sozinho.

## Como saber se funcionou

- A tela inicial mostra o dashboard com ícones.
- `SPC` abre o menu de atalhos (`which-key`) no modo normal do Evil.
- `SPC t T` alterna entre o tema escuro e o claro.
- Em um `.astro`, a modeline mostra o Eglot ativo.

## Problemas comuns

| Sintoma | O que fazer |
|---|---|
| Pacote não encontrado ao iniciar | `M-x package-refresh-contents` e reinicie |
| Ícones quebrados (quadrados) | `M-x nerd-icons-install-fonts` e reinicie |
| `Cannot load language definition` | `M-x my/treesit-install-grammars` |
| `typescript.tsdk init option is required` | `npm i -D typescript@6` no projeto |
| `TypeScript não encontrado` | Mesmo comando acima, na pasta do projeto |
| Formatação ao salvar não funciona | Instale o `prettier-plugin-astro` no projeto |
| `SPC` não faz nada | Confirme que está no modo normal (aperte `ESC`) |
| `void-variable evil-mode-buffers` | Versões misturadas do Evil: `M-x package-reinstall` em `evil`, `evil-collection`, `evil-surround`, `evil-commentary` e `evil-goggles`, e reinicie |

## Depois de aprovar

Se decidir trocar o Doom por esta configuração, faça backup do Doom antes e
só então mova a pasta:

```bash
mv ~/.config/emacs ~/.config/emacs-doom-backup
mv ~/emacs-vanilla ~/.config/emacs
```
