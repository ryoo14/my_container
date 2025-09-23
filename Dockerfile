FROM debian:bookworm-slim

WORKDIR /root

RUN apt-get update && \
    apt-get install -y build-essential git curl vim silversearcher-ag zip unzip locales-all bash-completion ca-certificates --no-install-recommends && \
    rm -rf /var/lib/apt/lists/*

RUN git clone https://github.com/ryoo14/dotfiles && \
    ln -sf /root/dotfiles/.bashrc .bashrc && \
    ln -sf /root/dotfiles/.vim .vim && \
    ln -sf /root/dotfiles/.vimrc .vimrc

SHELL ["/bin/bash", "-o", "pipefail", "-c"]
RUN curl -fsSL https://deno.land/install.sh | bash -s -- -y && \
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash && \
    git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf && \
    ~/.fzf/install --no-key-bindings --no-completion --no-update-rc --no-bash --no-zsh --no-fish

SHELL ["/bin/bash", "-l", "-c"]
RUN nvm install --lts && \
    sed -i 's/colorscheme monochrome/" colorscheme monochrome/g' /root/.vimrc && \
    vim -c ":PlugInstall" -c ":q" -c ":q" && \
    sed -i 's/" colorscheme monochrome/colorscheme monochrome/g' /root/.vimrc && \
    mkdir /root/.vim/backup && mkdir /root/.vim/undo

CMD ["bash"]
