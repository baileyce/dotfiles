#            _              
#    _______| |__  _ __ ___ 
#   |_  / __| '_ \| '__/ __|
#  _ / /\__ \ | | | | | (__ 
# (_)___|___/_| |_|_|  \___|

# 補完           |completion-index|
# 履歴           |history-index|
# エイリアス     |alias-index|
# オプション     |option-index|
# プロンプト     |prompt-index|

# 環境変数
export PATH=$PATH:$HOME/tools

# Viライクな操作を有効にする
bindkey -v

# 色を有効化
autoload -Uz colors; colors

# deleteキーとbackspaceキーを有効化
bindkey '^?' backward-delete-char
bindkey '^[[3~' delete-char

# lsを色付きにする
export LSCOLORS=gxfxcxdxbxegedabagacag
export LS_COLORS='di=36;40:ln=35;40:so=32;40:ex=31;40:bd=34;46:cd=34;43:su=30;41:sg=30;46:tw=30;42:ow=30;46'
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}

# ブックマークみたいなやつ
#hash -d hoge = /long/path/to/hoge


#=================================================
# 補完 *completion-index*
#=================================================

# 自動補完を有効にする
autoload -Uz compinit; compinit

# 小文字大文字混同
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

# ../の後は今いるディレクトリを補完しない
zstyle ':completion*' ignore-parents parent pwd ..

# tabで表示した補完候補をtabで選択
zstyle ':completion:*:default' menu select=1

# 選択中のアイテムをハイライト
zstyle ':completion:*' menu select


#=================================================
# 履歴 *history-index*
#=================================================

HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000

# ctrl+{p, n}で履歴を検索
bindkey '^P' history-search-backward
bindkey '^N' history-search-forward


#=================================================
# エイリアス *alias-index*
#=================================================

alias la='ls -a'
alias ll='ls -l'
alias lla='ls -la'

alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

alias mkdir='mkdir -p'

alias spacemacs='emacs -nw'

alias ls='ls -F --color'


#=================================================
# オプション *option-index*
#=================================================

# ディレクトリ名でcdする
setopt autocd

# cdした先のディレクトリをディレクトリスタックに追加する
# 例：`cd+<Tab>`
setopt autopushd

# pushdしたとき、ディレクトリがスタックにある場合追加しない
setopt pushdignoredups

# 入力したコマンドが履歴に含まれる場合、古い履歴から削除
setopt histignorealldups

# 重複した履歴を表示しない
setopt histignoredups

# コマンドがスペースで始まる場合、履歴へ追加しない
setopt histignorespace

# リスト表示のときにはじめから挿入する
setopt menucomplete

# ファイル生成パターンのエラーを表示しない
setopt nomatch

# ヒストリファイルをセッションごとに上書きする
setopt appendhistory 

# タイポを修正
setopt correct

# 候補の表示をコンパクトにする
setopt listpacked

# オプションの=の後の補完をする
setopt magicequalsubst

# 履歴を共有する
setopt share_history

# コマンド実行時に右プロンプトを削除する
setopt transient_rprompt

# 余分な空白は詰めて記録
setopt histreduceblanks

# 拡張globを無効
unsetopt extendedglob

# エラー時にビープを鳴らさない
unsetopt beep

# 出力されなかった行を非通知
unsetopt promptsp

# バックグラウンドjobが終了しても通知しない
unsetopt notify


#=================================================
# transfer.sh
#=================================================

transfer() {
    # check arguments
    if [ $# -ne 1 ]; then
        echo -e "Wrong arguments specified. Usage:\ntransfer /tmp/test.md\ncat /tmp/test.md | transfer test.md"
        return 1
    fi

    # get temporary filename, output is written to this file so show progress can be showed
    tmpfile="$( mktemp -t transferXXX )"

    # upload stdin or file
    file="$1"

    if tty -s; then
        basefile="$( basename "$file" | sed -e 's/[^a-zA-Z0-9._-]/-/g' )"

        if [ ! -e $file ]; then
            echo "File $file doesn't exists."
            return 1
        fi

        if [ -d $file ]; then
            # zip directory and transfer
            zipfile="$( mktemp -t transferXXX.zip )"
            cd "$(dirname "file")" && zip -r -q - "$(basename "$file")" >> "$zipfile"
            curl --progress-bar --upload-file "$zipfile" "https://transfer.sh/$basefile.zip" >> "$tmpfile"
            rm -f $zipfile
        else
            # transfer file
            curl --progress-bar --upload-file "$file" "https://transfer.sh/$basefile" >> "$tmpfile"
        fi
    else
        # transfer pipe
        curl --progress-bar -upload-file "-" "https://transfer.sh/$file" >> "$tmpfile"
    fi

    # cat output link
    cat "$tmpfile"
    echo

    # cleanup
    rm -f "$tmpfile"
}


#=================================================
# プロンプト *prompt-index*
#=================================================

NEWLINE=$'\n'

if echo $TTY | grep pts > /dev/null; then
    ARROW1='──'
    ARROW2='──'
    ARROW3='╭─╴'
    ARROW4='│'
    ARROW5='╰─>'
else
    ARROW1='--'
    ARROW2='-->'
    ARROW3=',--'
    ARROW4='|'
    ARROW5='`->'
fi

function zle-line-init zle-keymap-select {
    case $KEYMAP in
    main|viins)
        VISTATE="$ARROW1 INSERT $ARROW1"
        ;;
    vicmd)
        VISTATE="$ARROW1 NORMAL $ARROW1"
        ;;
    esac

    PS1="%(?..%F{red}$ARROW2 %?)$NEWLINE%F{green}$ARROW3 %F{cyan}%n%f@%F{magenta}%m %f%~$NEWLINE%F{green}$ARROW4  %F{yellow} $VISTATE$NEWLINE%F{green}$ARROW5%f "
    PS2="%F{green}   %F{yellow} $VISTATE$NEWLINE%F{green}    %f"

    zle reset-prompt
}

function zle-line-finish {
    PS1="%(?..%F{red}$ARROW2 %?)$NEWLINE%F{green}$ARROW3 %F{cyan}%n%f@%F{magenta}%m %f%~$NEWLINE%F{green}$ARROW5 %f"
    PS2="%F{green}    %f"

    zle reset-prompt
}

zle -N zle-line-init
zle -N zle-keymap-select
zle -N zle-line-finish


#===================
# zsh-syntax-highlighting
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
