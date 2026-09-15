# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="/home/pedro/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="agnoster"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to automatically update without prompting.
# DISABLE_UPDATE_PROMPT="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
  git
  zsh-autosuggestions
  pyenv
)

# Deduplica $PATH/$fpath automaticamente. Sem isso, .zprofile + plugin pyenv +
# .zshrc empilhavam as mesmas entradas 3x e o compinit varria os dirs repetidos.
typeset -U path PATH fpath FPATH

# Pula o compaudit (checagem de permissao dos dirs de completion) no startup.
ZSH_DISABLE_COMPFIX=true

source $ZSH/oh-my-zsh.sh

# User configuration
export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg#colour5"

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
alias zshconfig="vim ~/.zshrc"
alias vimconfig="vim ~/.vimrc"
alias tmuxconfig="vim ~/.tmux.conf"
# alias ohmyzsh="mate ~/.oh-my-zsh"
source ~/.aliases

# tabtab source for packages
# uninstall by removing these lines
#[[ -f ~/.config/tabtab/__tabtab.zsh ]] && . ~/.config/tabtab/__tabtab.zsh || true
#export PATH="/usr/local/opt/python@3.8/bin:$PATH"
#export PATH="${HOME}/.local/bin:$PATH"
#stty -ixon

# .zprofile ja rodou isso em shell de login; aqui so para shell nao-login.
if [[ -z "$HOMEBREW_PREFIX" ]] && [ -x /home/linuxbrew/.linuxbrew/bin/brew ]; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

export NVM_DIR="$HOME/.nvm"
[ -s "/home/linuxbrew/.linuxbrew/opt/nvm/nvm.sh" ] && \. "/home/linuxbrew/.linuxbrew/opt/nvm/nvm.sh"  # This loads nvm
[ -s "/home/linuxbrew/.linuxbrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/home/linuxbrew/.linuxbrew/opt/nvm/etc/bash_completion.d/nvm"


export EDITOR="nvim"

export PYTHON_BUILD_ARIA2_OPTS="-x 10 -k 1M"
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
# pyenv init nao vai aqui: o .zprofile roda `pyenv init --path` e o plugin pyenv
# do oh-my-zsh roda `--path` + `- --no-rehash`. Repetir custava ~70ms por shell.

# Flags usadas so por `pyenv install` ao compilar Python.
# Uma chamada ao brew em vez de tres: eram ~128ms por shell.
if command -v brew >/dev/null 2>&1; then
  _openssl_prefix="$(brew --prefix openssl)"
  export LDFLAGS="-Wl,-rpath,${_openssl_prefix}/lib"
  export CPPFLAGS="-I${_openssl_prefix}/include"
  export CONFIGURE_OPTS="--with-openssl=${_openssl_prefix}"
  unset _openssl_prefix
fi

export PATH="/home/linuxbrew/.linuxbrew/opt/libpq/bin:$PATH"
export PATH="$HOME/.yarn/bin:$PATH"

envchange(){
    context_name=$(kubectl config get-contexts | awk '{print $2}' | grep $1)
    kubectl config use-context $context_name
    gcloud config configurations activate $1
}

# thefuck custa ~160ms de Python no startup. Carrega no primeiro uso.
fuck() {
  unfunction fuck
  eval "$(thefuck --alias)"
  fuck "$@"
}
