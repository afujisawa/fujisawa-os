# fujisawa-os &nbsp; [![bluebuild build badge](https://github.com/afujisawa/fujisawa-os/actions/workflows/build.yml/badge.svg)](https://github.com/afujisawa/fujisawa-os/actions/workflows/build.yml)

See the [BlueBuild docs](https://blue-build.org/how-to/setup/) for quick setup instructions for setting up your own repository based on this template.

After setup, it is recommended you update this README to describe your custom image.

## Installation

> [!WARNING]  
> [This is an experimental feature](https://www.fedoraproject.org/wiki/Changes/OstreeNativeContainerStable), try at your own discretion.

To rebase an existing atomic Fedora installation to the latest build:

- First rebase to the unsigned image, to get the proper signing keys and policies installed:
  ```
  rpm-ostree rebase ostree-unverified-registry:ghcr.io/afujisawa/fujisawa-os:latest
  ```
- Reboot to complete the rebase:
  ```
  systemctl reboot
  ```
- Then rebase to the signed image, like so:
  ```
  rpm-ostree rebase ostree-image-signed:docker://ghcr.io/afujisawa/fujisawa-os:latest
  ```
- Reboot again to complete the installation
  ```
  systemctl reboot
  ```

The `latest` tag will automatically point to the latest build. That build will still always use the Fedora version specified in `recipe.yml`, so you won't get accidentally updated to the next major version.

## Desenvolvimento em C (toolbox)

A imagem traz as ferramentas de **edição** de C: o `clangd` (autocompletar, erros e navegação no Zed), o `clang-format` (formatação ao salvar) e os cabeçalhos padrão da biblioteca C (`glibc-devel`). O **compilador** e o depurador ficam num container do [toolbox](https://containertoolbx.org/), para manter o sistema limpo. A sua pasta pessoal é a mesma dentro e fora do container, então os projetos ficam acessíveis dos dois lados.

1. Crie o container (uma vez):
   ```bash
   toolbox create c-dev
   ```
2. Entre no container e instale o compilador e as ferramentas (uma vez):
   ```bash
   toolbox enter c-dev
   sudo dnf install -y gcc make gdb bear valgrind
   ```
3. Compile e depure normalmente, dentro do container:
   ```bash
   toolbox enter c-dev
   cd ~/projetos/meu-projeto
   make                       # ou: gcc -Wall -Wextra -g main.c -o main
   gdb ./main
   ```
4. Gere o `compile_commands.json`, para o `clangd` (no Zed) usar as mesmas opções de compilação do projeto:
   ```bash
   bear -- make
   ```

Para rodar um comando sem entrar no container: `toolbox run -c c-dev make`.

Bibliotecas extras (por exemplo, `ncurses-devel`) devem ser instaladas no container, para compilar:
```bash
toolbox run -c c-dev sudo dnf install -y ncurses-devel
```
Os cabeçalhos dessas bibliotecas ficam só dentro do container, então o `clangd` do sistema não os enxerga e o Zed marca o `#include` como erro (a compilação funciona normalmente). Para o editor também reconhecê-los, instale o mesmo pacote no sistema e reinicie:
```bash
rpm-ostree install ncurses-devel
systemctl reboot
```

## ISO

If build on Fedora Atomic, you can generate an offline ISO with the instructions available [here](https://blue-build.org/how-to/generate-iso/#_top). These ISOs cannot unfortunately be distributed on GitHub for free due to large sizes, so for public projects something else has to be used for hosting.

## Verification

These images are signed with [Sigstore](https://www.sigstore.dev/)'s [cosign](https://github.com/sigstore/cosign). You can verify the signature by downloading the `cosign.pub` file from this repo and running the following command:

```bash
cosign verify --key cosign.pub ghcr.io/afujisawa/fujisawa-os
```
