FROM ubuntu

LABEL maintainer="Coderaiser"
LABEL org.opencontainers.image.source="https://github.com/coderaiser/cloudcmd"

RUN mkdir -p /usr/src/cloudcmd

WORKDIR /usr/src/cloudcmd

COPY package.json /usr/src/cloudcmd/

ENV DEBIAN_FRONTEND=noninteractive \
    NVM_DIR=/usr/local/src/nvm \
    npm_config_cache=/tmp/npm-cache

ARG GO_VERSION=1.21.2
ARG NVIM_VERSION=0.12.0
ARG UBUNTU_DEPS="libatomic1 curl wget git net-tools iproute2"

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get autoremove && \
    apt-get install -y ${UBUNTU_DEPS} less ffmpeg net-tools netcat-openbsd mc iputils-ping vim bat fzf locales sudo command-not-found ncdu aptitude htop btop hexyl && \
    echo "> Update command-not-found database. Run 'sudo apt update' to populate it." && \
    apt-get update && \
    apt-get autoremove && \
    apt-get clean && \
    echo "> install nvm" && \
    mkdir $NVM_DIR && \
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.4/install.sh | bash && \
    . ${NVM_DIR}/nvm.sh && \
    nvm i node && \
    ln -fs /${NVM_DIR}/versions/node/$(node -v)/bin/node /usr/local/bin/node && \
    echo "> install palabra" && \
    npm i palabra -g && \
    echo "> install rust go deno bun fasm nvim" && \
    palabra i rust go deno bun fasm nvim -d /usr/local/src && \
    echo "> install npm globals" && \
    bun i wisdom nupdate version-io redrun superc8 supertape madrun redlint putout renamify-cli runny redfork -g && \
    echo "> install gritty" && \
    bun r gritty --omit dev && \
    bun i gritty --omit dev && \
    bun pm cache rm && \
    echo "> setup git" && \
    git config --global core.whitespace -trailing-space && \
    git config --global pull.rebase true && \
    echo "> configure bash" && \
    echo "alias ls='ls --color=auto'" >> /etc/bash.bashrc && \
    echo "alias buni='bun i --no-save'" >> /etc/bash.bashrc && \
    echo "alias bat='batcat'" >> /etc/bash.bashrc && \
    echo ". /usr/local/src/nvm/nvm.sh" >> /etc/bash.bashrc && \
    echo 'PS1="\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ "' >> /etc/bash.bashrc && \
    echo "> setup inputrc" && \
    echo "set editing-mode vi" >> /etc/inputrc && \
    echo "TAB: menu-complete" >> /etc/inputrc && \
    echo "set UTF-8" && \
    echo " > configure languages" && \
    echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && \
    echo "ru_RU.UTF-8 UTF-8" >> /etc/locale.gen && \
    echo "uk_UA.UTF-8 UTF-8" >> /etc/locale.gen && \
    echo "es_ES.UTF-8 UTF-8" >> /etc/locale.gen && \
    echo "ja_JP.UTF-8 UTF-8" >> /etc/locale.gen && \
    echo "el_GR.UTF-8 UTF-8" >> /etc/locale.gen && \
    locale-gen

COPY . /usr/src/cloudcmd

WORKDIR /

ENV cloudcmd_terminal=true \
    cloudcmd_terminal_path=gritty \
    cloudcmd_open=false \
    PATH=node_modules/.bin:$PATH \
    PATH=~/.local/bin:$PATH \
    BUN_INSTALL_CACHE_DIR=/tmp/bun-cache \
    DENO_DIR=/tmp/deno-cache \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8 \
    TERM=xterm-256color

EXPOSE 8000

ENTRYPOINT ["/usr/src/cloudcmd/bin/cloudcmd.js"]
