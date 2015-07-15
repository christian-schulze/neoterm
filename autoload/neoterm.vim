function! s:next_neoterm_id()
  let g:neoterm.last_id += 1
  return g:neoterm.last_id
endfunction

function! neoterm#new()
  if !has_key(g:neoterm, 'term')
    exec "source " . globpath(&rtp, "autoload/neoterm.term.vim")
  end

  let current_window = s:create_split()

  let instance = g:neoterm.term.new(s:next_neoterm_id())
  let g:neoterm[instance.id] = instance
  call instance.mappings()

  silent exec current_window . "wincmd w | set noinsertmode"
endfunction

function! s:create_split()
  let current_window = winnr()

  if g:neoterm_position == "horizontal"
    exec "botright ".g:neoterm_size." new"
  else
    exec "botright vert".g:neoterm_size." new"
  end

  return current_window
endfunction

function! neoterm#open()
  if !neoterm#tab_has_neoterm()
    if g:neoterm.last_id < 1 || g:neoterm.open < 1
      call neoterm#new()
    else
      call g:neoterm.last().open()
    end
  end
endfunction

function! neoterm#close()
  call g:neoterm.last().close()
endfunction

function! neoterm#do(command)
  call neoterm#exec([a:command, ""])
endfunction

function! neoterm#exec(command)
  call neoterm#open()
  call g:neoterm.last().exec(a:command)
endfunction

function! neoterm#map_for(command)
  exec "nnoremap <silent> "
        \ . g:neoterm_automap_keys .
        \ " :T " . neoterm#expand_cmd(a:command) . "<cr>"
endfunction

" Internal: Expands "%" in commands to current file full path.
function! neoterm#expand_cmd(command)
  return substitute(a:command, "%", expand("%:p"), "g")
endfunction

function! neoterm#tab_has_neoterm()
  if g:neoterm.last_id > 0 && g:neoterm.open > 0
    let buffer_id = g:neoterm.last().buffer_id
    return bufexists(buffer_id) > 0 && bufwinnr(buffer_id) != -1
  end
endfunction

" Internal: Clear the current neoterm buffer. (Send a <C-l>)
function! neoterm#clear()
  silent call neoterm#exec("\<c-l>")
endfunction

" Internal: Kill current process on neoterm. (Send a <C-c>)
function! neoterm#kill()
  silent call neoterm#exec("\<c-c>")
endfunction

function! neoterm#last()
  if g:neoterm.last_id > 0 && g:neoterm.open > 0
    return g:neoterm[g:neoterm.last_id]
  end
endfunction

function! neoterm#has_any()
  return g:neoterm.open > 0
endfunction
