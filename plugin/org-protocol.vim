"Emacs Org-mode protocol
"
"
"launch your Emacs Client from vim, and capture a file or store link.

"Author: Cyrus Baow
"Email: cy@baow.com
"Version: 0.1
"Date: 2013-05-30
"

let g:cy_emacs_org_command = "!emacsclient -c "

let g:cy_vstr = ''

function Cy_GetOrgStr(type) 
    let full_path = fnamemodify(bufname('%'), ":p")
    let title = fnamemodify(bufname('%'), ":t")

    "let title_path = fnamemodify(full_path, ":h").'/title'
    "if filereadable(title_path)
    "   let title = readfile(title_path)[0]
    "endif

    let org_type = 'capture'
    if a:type == 'link' || a:type=='v_link'
        let org_type = 'store-link'
    endif

    return 'org-protocol://'.org_type.'://file:'. substitute(full_path, '/', '%2F', 'g') . '/' . substitute(title, '/', '%2F', 'g').'/'

endfunction

function! CY_GetVisualStr(type, ...)
  let sel_save = &selection
  let &selection = "inclusive"
  let reg_save = @@

  if a:0  " Invoked from Visual mode, use '< and '> marks.
    silent exe "normal! `<" . a:type . "`>y"
  elseif a:type == 'line'
    silent exe "normal! '[V']y"
  elseif a:type == 'block'
    silent exe "normal! `[\<C-V>`]y"
  else
    silent exe "normal! `[v`]y"
  endif

  let g:cy_vstr = @@

  let &selection = sel_save
  let @@ = reg_save
endfunction

function CY_Org(type)
  let org_str = Cy_GetOrgStr(a:type)
  if a:type=='v_link' || a:type=='v_cap'
    call CY_GetVisualStr(visualmode(), 1)
    let info_str = "\n# File: " . fnamemodify(bufname('%'), ":p") . "\n# Line Number:" . line(".") . "\n# Column Number:" . col(".") . "\n#+BEGIN_SRC\n". g:cy_vstr . "\n#+END_SRC"
    let org_str = org_str . substitute(info_str, '/', '%2F', 'g') 
  endif
  exe g:cy_emacs_org_command . shellescape(org_str, 1)
endfunction

nmap <silent> <A-n> :<C-U>call CY_Org('cap')<CR>
vmap <silent> <A-n> :<C-U>call CY_Org('v_cap')<CR>
nmap <silent> <A-l> :<C-U>call CY_Org('link')<CR>


