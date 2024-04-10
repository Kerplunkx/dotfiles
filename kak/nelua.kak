hook global BufCreate .*[.](nelua) %{
    set-option buffer filetype lua
}

