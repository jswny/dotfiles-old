FROM ubuntu:19.10

# Set environment variables for the build only (these won't persist when you run the container)
ARG DEBIAN_FRONTEND=noninteractive
# Set XDG variables
ARG XDG_CONFIG_HOME=/root/.config
ARG XDG_DATA_HOME=/root/.local/share
ARG XDG_CACHE_HOME=/root/.cache
ARG HOME=/root

# Set environment variables (these will persist at runtime)
ENV TERM xterm-256color
ENV XDG_CONFIG_HOME=${XDG_CONFIG_HOME}
ENV XDG_DATA_HOME=${XDG_DATA_HOME}
ENV XDG_CACHE_HOME=${XDG_CACHE_HOME}

# Remove the exlusions for man pages and such so they get installed
# This will only install man pages for packages that aren't built in
# For example, "man ls" still won't work, but "man fish" will
# To restore ALL man pages, run "yes | unminimize"
# However, this will take a long time and install a lot of extra packages as well
RUN rm /etc/dpkg/dpkg.cfg.d/excludes

# Update packages
RUN apt-get update

# Install essentials
RUN apt-get install -y \
    man-db \
    locales \
    apt-utils \
    make \
    cmake \
    git \
    curl \
# Allows usage of apt-add-repository
    software-properties-common

# Generate the correct locale and reconfigure the locales so they are picked up correctly
RUN locale-gen en_US.UTF-8
RUN dpkg-reconfigure locales

# Set the correct locale variables for the build as they won't be set correctly until logging into the system
# This is needed for when the BEAM is run when 
# This is per the following suggestion: https://github.com/elixir-lang/elixir/issues/3548
# We need to set this after we generate the locales otherwise locale-gen will genearate an error
ARG LC_ALL=en_US.UTF-8

# Install Fish
RUN apt-add-repository ppa:fish-shell/release-3
RUN apt-get update
RUN apt-get install -y fish
# Change default shell to Fish
RUN chsh -s $(which fish)

# Install Fisher (Fish plugin manager)
RUN curl --create-dirs -sLo ~/.config/fish/functions/fisher.fish https://git.io/fisher

# Install Erlang
# This uses the Erlang Solutions repo
RUN curl -sLo $XDG_CACHE_HOME/erlang-solutions_2.0_all.deb --create-dirs https://packages.erlang-solutions.com/erlang-solutions_2.0_all.deb
RUN dpkg -i $XDG_CACHE_HOME/erlang-solutions_2.0_all.deb
RUN rm $XDG_CACHE_HOME/erlang-solutions_2.0_all.deb
RUN apt-get update
RUN apt-get install -y esl-erlang

# Install Elixir
RUN apt-get install -y elixir

# Install Rebar3
RUN mix local.rebar --force

# Install Hex
RUN mix local.hex --force

# Install and build Elixir-LS
ARG ELIXIR_LS_VERSION=0.3.0
RUN git clone https://github.com/elixir-lsp/elixir-ls.git --branch v${ELIXIR_LS_VERSION} --depth 1 /usr/local/share/elixir-ls
WORKDIR /usr/local/share/elixir-ls
RUN mix deps.get
RUN mix compile
RUN mix elixir_ls.release
RUN ln -s /usr/local/share/elixir-ls/release/language_server.sh /usr/local/bin/elixir-ls.sh 

# Install Pip for Python 2 and 3
# Ubuntu already comes with Python 2 and 3 installed
RUN apt-get install -y \
    python-pip \
    python3-pip
# Upgrade Python 2 and 3 Pip versions
RUN pip2 install --upgrade pip
RUN pip3 install --upgrade pip

# Install Fuck
RUN pip3 install thefuck

# Install Python 2 and 3 providers for NeoVim
RUN pip2 install --upgrade pynvim
RUN pip3 install --upgrade pynvim

# Install NeoVim
RUN add-apt-repository ppa:neovim-ppa/unstable
RUN apt-get update
RUN apt-get install -y neovim

# Install vim-plug
RUN curl --create-dirs -sfLo $XDG_DATA_HOME/nvim/site/autoload/plug.vim https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# Enable Solarized dircolors
RUN git clone --depth 1 https://github.com/seebi/dircolors-solarized.git $XDG_DATA_HOME/dircolors-solarized

# Install Tmux compilation dependencies
RUN apt-get install -y \
    libevent-dev \
    ncurses-dev \
    bison \
    pkg-config \
    autotools-dev \
    automake

# Install Tmux from source
# Older versions than 2.9 do not work with some .tmux.conf syntax
RUN mkdir -p $XDG_CACHE_HOME
RUN git clone --depth 1 --branch 3.1 https://github.com/tmux/tmux.git $XDG_CACHE_HOME/tmux
WORKDIR $XDG_CACHE_HOME/tmux
RUN sh autogen.sh
RUN ./configure && make
RUN make install
RUN rm -rf $XDG_CACHE_HOME/tmux

# Install TPM (Tmux Plugin Manager)
RUN git clone --depth 1 https://github.com/tmux-plugins/tpm $XDG_DATA_HOME/tmux/plugins/tpm

# Install FZF without Bash or ZSH support
RUN git clone --depth 1 https://github.com/junegunn/fzf.git $XDG_DATA_HOME/fzf
RUN $XDG_DATA_HOME/fzf/install --all --no-bash --no-zsh --xdg

# Install FD
ARG FD_VERSION=7.4.0
RUN curl --create-dirs -sLo $XDG_CACHE_HOME/fd_{$FD_VERSION}_amd64.deb https://github.com/sharkdp/fd/releases/download/v{$FD_VERSION}/fd_{$FD_VERSION}_amd64.deb
RUN dpkg -i $XDG_CACHE_HOME/fd_${FD_VERSION}_amd64.deb
RUN rm $XDG_CACHE_HOME/fd_${FD_VERSION}_amd64.deb

# Install Bat
# Force overwrites when installing the .deb package because Bat tries to install its completions into the built-in Fish completions folder (which is managed by the Fish package)
# See: https://github.com/sharkdp/bat/issues/651
ARG BAT_VERSION=0.12.1
RUN curl --create-dirs -sLo $XDG_CACHE_HOME/bat_{$BAT_VERSION}_amd64.deb https://github.com/sharkdp/bat/releases/download/v${BAT_VERSION}/bat_{$BAT_VERSION}_amd64.deb
RUN dpkg -i --force-overwrite $XDG_CACHE_HOME/bat_{$BAT_VERSION}_amd64.deb
RUN rm $XDG_CACHE_HOME/bat_${BAT_VERSION}_amd64.deb

# Set the root home directory as the working directory
WORKDIR $HOME

# Add the dotfiles into the container and set them up
ADD . $XDG_CONFIG_HOME/dotfiles
WORKDIR $XDG_CONFIG_HOME/dotfiles
RUN $XDG_CONFIG_HOME/dotfiles/scripts/setup.sh 

WORKDIR $HOME

# Run a Fish prompt by default
# Override this as needed
CMD /usr/bin/fish
