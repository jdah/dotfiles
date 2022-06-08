export PATH="${PATH:+${PATH}:}/opt/nim/bin"
export PATH="${PATH:+${PATH}:}/opt/zig/build/bin"
export PATH="${PATH:+${PATH}:}/opt/zls/zig-out/bin"
export PATH="${PATH:+${PATH}:}/opt/genie"

# ALIASES
alias vim=nvim

# git
alias gap="git add -p"
alias gc="git commit"
alias gcm="git commit -m"
alias gp="git push"
alias gpu="git pull"
alias gck="git checkout"

# rust env
source $HOME/.cargo/env

# homebrew in path
eval $(/opt/homebrew/bin/brew shellenv)

if [ -z "$TMUX" ]; then
  exec arch -arm64 tmux
fi

# move annoying .zcompdump files into a better hidden directory
autoload -Uz compinit
compinit -d ~/.config/zsh/.zcompdump

# BEGIN FZF CONFIG

# Setup fzf
# ---------
if [[ ! "$PATH" == */usr/local/opt/fzf/bin* ]]; then
  export PATH="${PATH:+${PATH}:}/usr/local/opt/fzf/bin"
fi

# Auto-completion
# ---------------
# [[ $- == *i* ]] && source "/usr/local/opt/fzf/shell/completion.zsh" 2> /dev/null

# END FZF CONFIG

# Path to your oh-my-zsh installation.
export ZSH="/Users/jdh/.oh-my-zsh"

ZSH_THEME="geoffgarside"

# oh-my-zsh plugins
plugins=(
  git
  zsh-autosuggestions
  zsh-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh

# preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='nvim'
else
  export EDITOR='vim'
fi

export PATH="/usr/local/opt/openjdk/bin:$PATH"

# CUSTOM
set +m

# zsh-autosuggest config
export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#666666"
export ZSH_AUTOSUGGEST_STRATEGY=(history completion)

if type rg &> /dev/null; then
  export FZF_DEFAULT_COMMAND='rg --files'
  export FZF_DEFAULT_OPTS='-m --height 50% --border'
fi

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
[ -f "/Users/jdh/.ghcup/env" ] && source "/Users/jdh/.ghcup/env" # ghcup-env
