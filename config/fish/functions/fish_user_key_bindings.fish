function fish_user_key_bindings
    # Ctrl-f for auto completion
    for mode in insert default visual
        bind -M $mode \cf forward-char
    end
    # bind jk to exit insert mode
    bind -M insert jk "if commandline -P; commandline -f cancel; else; set fish_bind_mode default; commandline -f backward-char force-repaint; end"
end

