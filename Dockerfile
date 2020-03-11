FROM ubuntu:19.10

# Set environment variables for the build only (these won't persist when you run the container)
ARG DEBIAN_FRONTEND=noninteractive
ARG USER=user1
ARG XDG_CONFIG_HOME=/home/${USER}/.config
ARG PACKAGE_SOURCE_HOME=/home/${USER}/.local/src
ARG HOME=/home/${USER}

# Set environment variables (these will persist at runtime)
ENV TERM xterm-256color

# Enable failure on pipefail
# This ensures that if any call in a pipe fails, the whole pipe fails
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Remove the exlusions for man pages and such so they get installed
# This will only install man pages for packages that aren't built in
# For example, "man ls" still won't work, but "man fish" will
# To restore ALL man pages, run "yes | unminimize"
# However, this will take a long time and install a lot of extra packages as well
RUN rm /etc/dpkg/dpkg.cfg.d/excludes

# Generate the correct locale and reconfigure the locales so they are picked up correctly
RUN apt-get update \
    && apt-get install --no-install-recommends -y locales \
    man-db \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && locale-gen --purge en_US.UTF-8 \
    && dpkg-reconfigure locales

# Set the correct locale variables for the build as they won't be set correctly until logging into the system
# This is needed for when the BEAM is run when 
# This is per the following suggestion: https://github.com/elixir-lang/elixir/issues/3548
# We need to set this after we generate the locales otherwise locale-gen will genearate an error
ARG LC_ALL=en_US.UTF-8

# Add a new user and add them to sudoers
# Also allow the use of sudo with no password
# This is required to use sudo in the commands below
# From here, if we use sudo we need to use --preserve-env for sudo so that DEBIAN_FRONTEND=noninteractive is passed correctly to commands
# Setup sudo to be used in this Dockerfile without a password for the new user
# Allow chsh to be run without needing a password
RUN apt-get update \
    && apt-get install --no-install-recommends -y \
    sudo \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && useradd --create-home ${USER} \
    && usermod -aG sudo ${USER} \
    && echo "${USER} ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers \
    && sudo sed s/required/sufficient/g -i /etc/pam.d/chsh

# Install Brew dependencies
RUN apt-get update \
    && apt-get install -y \
    libc6 \
    gcc \
    make \
    curl \
    file \
    git \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Swith to the the new user and the new working directory
USER ${USER}
WORKDIR $HOME

# Add dotfiles into the container and run setup
# TODO: clean this up and setup as one layer
RUN /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"

RUN eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)" \
    && brew install \
    fish \
    tmux \
    neovim \
    fzf \
    fd \
    bat \
    git-delta \
    thefuck \
    python
RUN echo "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)" >> $HOME/.bashrc
COPY . $XDG_CONFIG_HOME/dotfiles
RUN sudo chown -R ${USER}:${USER} $HOME/.config $HOME/.cache
RUN $XDG_CONFIG_HOME/dotfiles/scripts/setup --debug

# Run a Fish prompt by default
# Override this as needed
CMD ["/home/linuxbrew/.linuxbrew/bin/fish"]
