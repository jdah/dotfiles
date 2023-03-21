export SHELL_SESSIONS_DISABLE=1

# history settings
export HISTFILE="/Users/jdh/.config/zsh/.zsh_history"
HISTSIZE=10000
SAVEHIST=10000
setopt appendhistory
setopt INC_APPEND_HISTORY
setopt SHARE_HISTORY

export PATH="${PATH:+${PATH}:}/opt/nim/bin"
export PATH="${PATH:+${PATH}:}/opt/zig/build/bin"
export PATH="${PATH:+${PATH}:}/opt/zls/zig-out/bin"
export PATH="${PATH:+${PATH}:}/opt/genie"
export PATH="/opt/homebrew/opt/llvm/bin:$PATH"
export PATH="~/.nimble/bin:$PATH"
export PATH="/opt/bin:$PATH"

# .zshrc, etc. are located here
if [ -z "$INTELLIJ_ENVIRONMENT_READER" ]; then
    export ZDOTDIR=~/.config/zsh
fi

. "$HOME/.cargo/env"
