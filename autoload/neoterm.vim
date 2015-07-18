function! s:next_neoterm_id()
  let g:neoterm.last_id += 1
  return g:neoterm.last_id
endfunction

" Internal: Creates a new neoterm buffer if there is no one.
"
" Returns: 1 if a new terminal was created, 0 otherwise.
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

" Internal: Creates a new neoterm buffer, or opens if it already exists.
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

" Public: Executes a command on terminal.
" Evaluates any "%" inside the command to the full path of the current file.
function! neoterm#do(command)
  let command = neoterm#expand_cmd(a:command)

  call neoterm#exec([command, ""])
endfunction

" Internal: Loads a terminal, if it is not loaded, and execute a list of
" commands.
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

" Internal: Open a new split with the current neoterm buffer if there is one.
"
" Returns: 1 if a neoterm split is opened, 0 otherwise.
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
