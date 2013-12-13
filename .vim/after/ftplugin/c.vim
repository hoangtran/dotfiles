" ViM indent file for C

setlocal indentexpr=GetMyCIndent()

function! GetMyCIndent()
    let theIndent = cindent(v:lnum)

    let m = matchstr(getline(v:lnum - 1),
    \                '^\s*\w\+\s\+\S\+.*=\s*{\ze[^;]*$')
    if !empty(m)
        let theIndent = len(m)
    endif

    return theIndent
endfunction
