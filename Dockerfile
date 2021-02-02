FROM ubuntu:groovy

# Set environment variables for the build only (these won't persist when you run the container)
ARG DEBIAN_FRONTEND=noninteractive
ARG USER=user1
ARG XDG_CONFIG_HOME=/home/${USER}/.config
ARG PACKAGE_SOURCE_HOME=/home/${USER}/.local/src
ARG HOME=/home/${USER}

# Pinned versions
ARG LOCALES_VERSION='2.32-0ubuntu3'
ARG MAN_DB_VERSION='2.9.3-2'
ARG SUDO_VERSION='1.9.1-1ubuntu1.1'
ARG GOSU_VERSION='1.12-1'
ARG GCC_VERSION='4:10.2.0-1ubuntu1'
ARG MAKE_VERSION='4.3-4ubuntu1'
ARG CA_CERTIFICATES_VERSION='20201027ubuntu0.20.10.1'
ARG CURL_VERSION='7.68.0-1ubuntu4.2'
ARG FILE_VERSION='1:5.38-5'
ARG GIT_VERSION='1:2.27.0-1ubuntu1'

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
    && apt-get install --no-install-recommends -y locales=${LOCALES_VERSION} \
    man-db=${MAN_DB_VERSION} \
    sudo=${SUDO_VERSION} \
    gosu=${GOSU_VERSION} \
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
# This is required to use sudo in the commands below
# From here, if we use sudo we need to use --preserve-env for sudo so that DEBIAN_FRONTEND=noninteractive is passed correctly to commands
# Setup sudo to be used in this Dockerfile without a password for the new user
# Allow chsh to be run without needing a password
# These are both needed to allow the setup script to run without input
RUN useradd --create-home ${USER} \
    && usermod -aG sudo ${USER} \
    && echo "${USER} ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers \
    && sed s/required/sufficient/g -i /etc/pam.d/chsh

# Install dependencies for setup
RUN apt-get update \
    && apt-get install --no-install-recommends -y \
    gcc=${GCC_VERSION} \
    make=${MAKE_VERSION} \
    ca-certificates=${CA_CERTIFICATES_VERSION} \
    curl=${CURL_VERSION} \
    file=${FILE_VERSION} \
    git=${GIT_VERSION} \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install Brew and add paths
RUN gosu user1:user1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"

# Install Brew packages
RUN eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)" && \
    brew install \
    fish \
    coreutils \
    tmux \
    neovim \
    fzf \
    fd \
    bat \
    git-delta \
    thefuck \
    shellcheck \
    python \
    erlang \
    elixir

# Add dotfiles into the container and run setup
COPY . $XDG_CONFIG_HOME/dotfiles
RUN chown -R ${USER}:${USER} $HOME \
    && gosu user1 $XDG_CONFIG_HOME/dotfiles/scripts/setup.sh --debug \
    && echo "eval $(/home/linuxbrew/.linuxbrew/bin/brew shellenv)" >> $HOME/.bashrc \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Switch to the the new user and the new working directory
USER ${USER}
WORKDIR $HOME

# Run a Fish prompt by default
# Override this as needed
CMD ["/home/linuxbrew/.linuxbrew/bin/fish"]
