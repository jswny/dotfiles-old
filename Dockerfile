FROM ubuntu:19.10

# Set environment variables for the build only (these won't persist when you run the container)
ARG DEBIAN_FRONTEND=noninteractive
# Set XDG variables
ARG XDG_CONFIG_HOME=/root/.config
ARG XDG_DATA_HOME=/root/.local/share
ARG XDG_CACHE_HOME=/root/.cache
ARG HOME=/root

# Set versions
ARG MAN_DB_VERSION=2.8.7-3
ARG LOCALES_VERSION=2.30-0ubuntu2
ARG APT_UTILS_VERSION=1.9.4
ARG MAKE_VERSION=4.2.1-1.2
ARG CMAKE_VERSION=3.13.4-1build1
ARG GIT_VERSION=1:2.20.1-2ubuntu1.19.10.1
ARG CURL_VERSION=7.65.3-1ubuntu3
ARG SOFTWARE_PROPERTIES_COMMON_VERSION=0.98.5
ARG FISH_VERSION=3.1.0-1~eoan
ARG GNUPG2_VERSION=2.2.12-1ubuntu3
ARG ERLANG_VERSION=1:22.2.6-1
ARG ELIXIR_VERSION=1.10.1-1
ARG ELIXIR_LS_VERSION=0.3.0
ARG PIP_VERSION=18.1-5
ARG PIP_SELF_VERSION=20.0.2
ARG BUILD_ESSENTIAL_VERSION=12.8ubuntu1
ARG PYTHON_DEV_VERSION=3.7.5-1
ARG PYTHON_SETUPTOOLS_VERSION=41.1.0-1
ARG THEFUCK_VERSION=3.29
ARG PYNVIM_VERSION=0.4.1
ARG NEOVIM_VERSION=0.4.3
ARG TMUX_VERSION=3.1
ARG LIBEVENT_DEV_VERSION=2.1.8-stable-4build1
ARG LIBNCURSES_DEV_VERSION=6.1+20190803-1ubuntu1
ARG BISON_VERSION=2:3.4.1+dfsg-4
ARG PKG_CONFIG_VERSION=0.29.1-0ubuntu3
ARG AUTOTOOLS_DEV_VERSION=20180224.1
ARG AUTOMAKE_VERSION=1:1.16.1-4ubuntu3
ARG FD_VERSION=7.4.0
ARG BAT_VERSION=0.12.1
ARG DELTA_VERSION=0.0.16

# Set environment variables (these will persist at runtime)
ENV TERM xterm-256color
ENV XDG_CONFIG_HOME=${XDG_CONFIG_HOME}
ENV XDG_DATA_HOME=${XDG_DATA_HOME}
ENV XDG_CACHE_HOME=${XDG_CACHE_HOME}

# Enable failure on pipefail
# This ensures that if any call in a pipe fails, the whole pipe fails
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Remove the exlusions for man pages and such so they get installed
# This will only install man pages for packages that aren't built in
# For example, "man ls" still won't work, but "man fish" will
# To restore ALL man pages, run "yes | unminimize"
# However, this will take a long time and install a lot of extra packages as well
RUN rm /etc/dpkg/dpkg.cfg.d/excludes

# Install essentials
RUN apt-get update \
    && apt-get install --no-install-recommends -y \
    man-db=${MAN_DB_VERSION} \
    locales=${LOCALES_VERSION} \
    apt-utils=${APT_UTILS_VERSION} \
    make=${MAKE_VERSION} \
    cmake=${CMAKE_VERSION} \
    git=${GIT_VERSION} \
    curl=${CURL_VERSION} \
    software-properties-common=${SOFTWARE_PROPERTIES_COMMON_VERSION} \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Generate the correct locale and reconfigure the locales so they are picked up correctly
RUN locale-gen en_US.UTF-8 \
    && dpkg-reconfigure locales

# Set the correct locale variables for the build as they won't be set correctly until logging into the system
# This is needed for when the BEAM is run when 
# This is per the following suggestion: https://github.com/elixir-lang/elixir/issues/3548
# We need to set this after we generate the locales otherwise locale-gen will genearate an error
ARG LC_ALL=en_US.UTF-8

# Install Fish
# Change default shell to Fish
RUN apt-add-repository ppa:fish-shell/release-3 \
    && apt-get update \
    && apt-get install --no-install-recommends -y fish=${FISH_VERSION} \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && chsh -s "$(command -v fish)"

# Install Fisher (Fish plugin manager)
RUN curl --create-dirs -sLo ~/.config/fish/functions/fisher.fish https://git.io/fisher

# Install Erlang
# This uses the Erlang Solutions repo
RUN apt-get update \
    && apt-get install --no-install-recommends -y gnupg2=${GNUPG2_VERSION} \
    && curl -sLo $XDG_CACHE_HOME/erlang-solutions_2.0_all.deb --create-dirs https://packages.erlang-solutions.com/erlang-solutions_2.0_all.deb \
    && dpkg -i $XDG_CACHE_HOME/erlang-solutions_2.0_all.deb \
    && rm $XDG_CACHE_HOME/erlang-solutions_2.0_all.deb \
    && apt-get update \
    && apt-get install --no-install-recommends -y esl-erlang=${ERLANG_VERSION} \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install Elixir
RUN apt-get update \
    && apt-get install --no-install-recommends -y elixir=${ELIXIR_VERSION} \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install Rebar3 and Hex
RUN mix local.rebar --force \
    && mix local.hex --force

# Install and build Elixir-LS
RUN git clone https://github.com/elixir-lsp/elixir-ls.git --branch v${ELIXIR_LS_VERSION} --depth 1 /opt/elixir-ls
WORKDIR /opt/elixir-ls
RUN mix deps.get \
    && mix compile \
    && mix elixir_ls.release \
    && ln -s /opt/elixir-ls/release/language_server.sh /usr/local/bin/elixir-ls.sh 

# Install Pip for Python 2 and 3
# Ubuntu already comes with Python 2 and 3 installed
RUN apt-get update \
    && apt-get install --no-install-recommends -y \
    python-pip=${PIP_VERSION} \
    python3-pip=${PIP_VERSION} \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && pip2 install --upgrade pip==${PIP_SELF_VERSION} \
    && pip3 install --upgrade pip==${PIP_SELF_VERSION}

# Install Fuck
RUN apt-get update \
    && apt-get --no-install-recommends install -y \
    build-essential=${BUILD_ESSENTIAL_VERSION} \
    python3-dev=${PYTHON_DEV_VERSION} \
    python3-pip=${PIP_VERSION} \
    python3-setuptools=${PYTHON_SETUPTOOLS_VERSION} \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && pip3 install thefuck==${THEFUCK_VERSION}

# Install Python 2 and 3 providers for NeoVim
RUN apt-get update \
    && apt-get install --no-install-recommends -y python-setuptools=${PYTHON_SETUPTOOLS_VERSION} \
    python3-setuptools=${PYTHON_SETUPTOOLS_VERSION} \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && pip2 install --upgrade pynvim==${PYNVIM_VERSION} \
    && pip3 install --upgrade pynvim==${PYNVIM_VERSION}

# Install NeoVim
RUN curl --create-dirs -sL https://github.com/neovim/neovim/releases/download/${NEOVIM_VERSION}/nvim-linux64.tar.gz | tar zx --directory /opt \
    && mv /opt/nvim-linux64 /opt/nvim \
    && ln -s /opt/nvim/bin/nvim /usr/local/bin/nvim

# Install vim-plug
RUN curl --create-dirs -sfLo $XDG_DATA_HOME/nvim/site/autoload/plug.vim https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# Enable Solarized dircolors
RUN git clone --depth 1 https://github.com/seebi/dircolors-solarized.git $XDG_DATA_HOME/dircolors-solarized

# Install Tmux
# Versions older 2.9 do not work with some .tmux.conf syntax
RUN apt-get update \
    && apt-get install --no-install-recommends -y \
    libevent-dev=${LIBEVENT_DEV_VERSION} \
    libncurses-dev=${LIBNCURSES_DEV_VERSION} \
    bison=${BISON_VERSION} \
    pkg-config=${PKG_CONFIG_VERSION} \
    autotools-dev=${AUTOTOOLS_DEV_VERSION} \
    automake=${AUTOMAKE_VERSION} \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir -p $XDG_CACHE_HOME \
    && git clone --depth 1 --branch ${TMUX_VERSION} https://github.com/tmux/tmux.git $XDG_CACHE_HOME/tmux
WORKDIR $XDG_CACHE_HOME/tmux
RUN sh autogen.sh \
    && ./configure && make \
    && make install
WORKDIR $HOME
RUN rm -rf $XDG_CACHE_HOME/tmux

# Install TPM (Tmux Plugin Manager)
RUN git clone --depth 1 https://github.com/tmux-plugins/tpm $XDG_DATA_HOME/tmux/plugins/tpm

# Install FZF without Bash or ZSH support
RUN git clone --depth 1 https://github.com/junegunn/fzf.git $XDG_DATA_HOME/fzf \
    && $XDG_DATA_HOME/fzf/install --all --no-bash --no-zsh --xdg

# Install FD
RUN curl --create-dirs -sLo $XDG_CACHE_HOME/fd_${FD_VERSION}_amd64.deb https://github.com/sharkdp/fd/releases/download/v${FD_VERSION}/fd_${FD_VERSION}_amd64.deb \
    && dpkg -i $XDG_CACHE_HOME/fd_${FD_VERSION}_amd64.deb \
    && rm $XDG_CACHE_HOME/fd_${FD_VERSION}_amd64.deb

# Install Bat
# Force overwrites when installing the .deb package because Bat tries to install its completions into the built-in Fish completions folder (which is managed by the Fish package)
# See: https://github.com/sharkdp/bat/issues/651
RUN curl --create-dirs -sLo $XDG_CACHE_HOME/bat_${BAT_VERSION}_amd64.deb https://github.com/sharkdp/bat/releases/download/v${BAT_VERSION}/bat_${BAT_VERSION}_amd64.deb \
    && dpkg -i --force-overwrite $XDG_CACHE_HOME/bat_${BAT_VERSION}_amd64.deb \
    && rm $XDG_CACHE_HOME/bat_${BAT_VERSION}_amd64.deb

# Install Delta
RUN curl --create-dirs -sLo $XDG_CACHE_HOME/git-delta_${DELTA_VERSION}_amd64.deb https://github.com/dandavison/delta/releases/download/${DELTA_VERSION}/git-delta_${DELTA_VERSION}_amd64.deb \
    && dpkg -i $XDG_CACHE_HOME/git-delta_${DELTA_VERSION}_amd64.deb \
    && rm $XDG_CACHE_HOME/git-delta_${DELTA_VERSION}_amd64.deb

# Add the dotfiles into the container and set them up
COPY . $XDG_CONFIG_HOME/dotfiles
RUN $XDG_CONFIG_HOME/dotfiles/scripts/setup.sh 

# Set the root home directory as the working directory
WORKDIR $HOME

# Run a Fish prompt by default
# Override this as needed
CMD ["/usr/bin/fish"]
