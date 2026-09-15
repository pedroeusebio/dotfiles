# Roda antes do .zshrc, entao o dedupe precisa comecar aqui.
typeset -U path PATH fpath FPATH

eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
export PYTHON_BUILD_ARIA2_OPTS="-x 10 -k 1M"
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init --path)"
