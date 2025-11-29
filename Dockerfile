FROM debian:bookworm-slim AS builder
RUN apt update && \
    apt install -y \
        build-essential \
        git \
        ca-certificates \
        libncurses-dev \
        python3-dev \
        liblua5.3-dev \
        libperl-dev \
        ruby-dev \
        --no-install-recommends && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /tmp
RUN git clone --depth 1 https://github.com/vim/vim
WORKDIR /tmp/vim/src

# create symlink for lua
RUN ln -s /usr/include/lua5.3 /usr/include/lua && \
    ln -sf /usr/lib/aarch64-linux-gnu/liblua5.3.so /usr/lib/liblua.so && \
    ln -sf /usr/lib/aarch64-linux-gnu/liblua5.3.so /usr/lib/aarch64-linux-gnu/liblua.so

RUN ./configure \
  --with-features=huge \
  --enable-gui=no \
  --enable-python3interp=yes \
  --enable-luainterp=yes \
  --with-lua-prefix=/usr \
  --enable-rubyinterp=yes \
  --enable-perlinterp=yes \
  --prefix=/usr/local

RUN make
RUN make install

FROM debian:bookworm-slim
COPY --from=builder /usr/local/bin/vim /usr/local/bin/vim
COPY --from=builder /usr/local/share/vim /usr/local/share/vim
RUN apt update && \
  apt install -y \
    build-essential \
    git \
    curl \
    wget \
    silversearcher-ag \
    zip \
    unzip \
    locales-all \
    bash-completion \
    ca-certificates \
    libncurses6 \
    python3 \
    libpython3.11 \
    liblua5.3-0 \
    libperl5.36 \
    libruby3.1 && \
  rm -rf /var/lib/apt/lists/*

WORKDIR /root
RUN git clone https://github.com/ryoo14/dotfiles && \
    ln -sf /root/dotfiles/.bashrc .bashrc && \
    ln -sf /root/dotfiles/.vim .vim && \
    ln -sf /root/dotfiles/.vimrc .vimrc
    # TODO: create symlink for other dotfiles

SHELL ["/bin/bash", "-o", "pipefail", "-c"]
RUN curl -fsSL https://deno.land/install.sh | bash -s -- -y && \
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash && \
    git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf && \
    ~/.fzf/install --no-key-bindings --no-completion --no-update-rc --no-bash --no-zsh --no-fish
#
SHELL ["/bin/bash", "-l", "-c"]
RUN nvm install --lts && \
    sed -i 's/^colorscheme/" colorscheme/g' /root/.vimrc && \
    vim -c ":PlugInstall" -c ":q" -c ":q" && \
    sed -i 's/^" colorscheme/colorscheme/g' /root/.vimrc && \
    mkdir /root/.vim/backup && mkdir /root/.vim/undo

# TODO: install lsp servers

WORKDIR /root/work
ENTRYPOINT ["vim"]
