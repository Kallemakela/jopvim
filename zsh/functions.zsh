function vi-yank-pbcopy {
    zle vi-yank
    echo "$CUTBUFFER" | pbcopy
}

cl() {
    tmpfile=$(mktemp)
    tee "$tmpfile"
    tail -n 1 "$tmpfile" | pbcopy
    rm "$tmpfile"
}

rspro() {
    src="$1"
    dest="$2"
    size=$(du -sk "$src" | awk '{print $1 * 1024}')
    rsync -avh "$src" "$dest" | pv -s "$size" > /dev/null
}

cdf() {
    target="$(fzf)"
    if [ -d "$target" ]; then
        cd "$target" || return
    else
        cd "$(dirname "$target")" || return
    fi
}

