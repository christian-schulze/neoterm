" Internal: Loads a terminal, if it is not loaded, and execute a list of
" commands.
function! neoterm#exec(list)
  let current_window = winnr()

  call neoterm#open()
  call jobsend(g:neoterm_terminal_jid, a:list)

  if g:neoterm_keep_term_open
    silent exec current_window . "wincmd w | set noinsertmode"
  else
    call jobsend(g:neoterm_terminal_jid, ["\<c-d>"])
    startinsert
  end
endfunction

" Internal: Loads a terminal, if it is not loaded, and execute a list of
" commands.
function! neoterm#exec_at(id, list)
  let current_window = winnr()

  call neoterm#show(a:id)
  call jobsend(g:neoterm[a:id].job_id, a:list)

  if g:neoterm_keep_term_open
    silent exec current_window . "wincmd w | set noinsertmode"
  else
    call jobsend(g:neoterm_terminal_jid, ["\<c-d>"])
    startinsert
  end
endfunction

" Internal: Creates a new neoterm buffer, or opens if it already exists.
function! neoterm#open()
  return neoterm#show() || neoterm#new()
endfunction

" Internal: Creates a new neoterm buffer if there is no one.
"
" Returns: 1 if a new terminal was created, 0 otherwise.
function! neoterm#new()
  let neoterm_id = s:neoterm_counter()
  let opts = extend(
        \ { 'name': 'NEOTERM-' . neoterm_id },
        \ neoterm#test#handlers()
        \ )

  exec <sid>split_cmd()
  echom 'new'
  let g:neoterm[neoterm_id] = {
        \ 'job_id': termopen([&sh], opts),
        \ 'buffer_id': bufnr('%')
        \ }
  call s:create_mappings(neoterm_id)
endfunction

function! s:create_mappings(id)
  if has_key(g:neoterm, a:id)
    let buffer_id = g:neoterm[a:id].buffer_id

    exec 'command! -complete=shellcmd Topen' . a:id . ' call neoterm#show(' . a:id . ')'
    exec 'command! -complete=shellcmd Tclose' . a:id . ' call neoterm#close_buffer(' . buffer_id . ')'
    exec 'command! -complete=shellcmd -nargs=+ T' . a:id . ' call neoterm#do_at(' . a:id . ', <q-args>)'
  else
    echoe 'There is no '.a:id.' neoterm.'
  end
endfunction

function! s:neoterm_counter()
  let g:neoterm.last_id += 1
  return g:neoterm.last_id
endfunction

" Internal: Open a new split with the current neoterm buffer if there is one.
"
" Returns: 1 if a neoterm split is opened, 0 otherwise.
function! neoterm#show(...)
  if !empty(a:000) && has_key(g:neoterm, a:1)
    if !neoterm#tab_has_this_neoterm(a:1)
      call s:show(a:1)
      return 1
    end
  elseif g:neoterm.last_id
    if !neoterm#tab_has_this_neoterm(g:neoterm.last_id)
      call  s:show(g:neoterm.last_id)
      return 1
    end
  end

  return 0
endfunction

function! s:show(neoterm_id)
  let buffer_id = g:neoterm[a:neoterm_id].buffer_id

  exec <sid>split_cmd()
  exec "buffer " . buffer_id
endfunction

function! s:split_cmd()
  if g:neoterm_position == "horizontal"
    return "botright ".g:neoterm_size." new"
  else
    return "botright vert".g:neoterm_size." new"
  end
endfunction

" Internal: Verifies if neoterm is open for current tab.
function! neoterm#tab_has_this_neoterm(id)
  return has_key(g:neoterm, a:id) &&
        \ bufexists(g:neoterm[a:id].buffer_id) > 0 &&
        \ bufwinnr(g:neoterm[a:id].buffer_id) != -1
endfunction

" Internal: Verifies if neoterm is open for current tab.
function! neoterm#tab_has_neoterm()
  return exists('g:neoterm_buffer_id') &&
        \ bufexists(g:neoterm_buffer_id) > 0 &&
        \ bufwinnr(g:neoterm_buffer_id) != -1
endfunction

" Public: Executes a command on terminal.
" Evaluates any "%" inside the command to the full path of the current file.
function! neoterm#do_at(id, command)
  let command = neoterm#expand_cmd(a:command)

  call neoterm#exec_at(a:id, [command, ''])
endfunction

" Public: Executes a command on terminal.
" Evaluates any "%" inside the command to the full path of the current file.
function! neoterm#do(command)
  let command = neoterm#expand_cmd(a:command)

  call neoterm#exec([command, ''])
endfunction

" Internal: Expands "%" in commands to current file full path.
function! neoterm#expand_cmd(command)
  return substitute(a:command, '%', expand('%:p'), 'g')
endfunction

" Internal: Closes/Hides all neoterm buffers.
function! neoterm#close_all()
  let all_buffers = range(1, bufnr('$'))

  for b in all_buffers
    if bufname(b) =~ "term:\/\/.*NEOTERM"
      call neoterm#close_buffer(b)
    end
  endfor
endfunction

" Internal: Closes/Hides a given buffer.
function! neoterm#close_buffer(buffer)
  if g:neoterm_keep_term_open
    if bufwinnr(a:buffer) > 0 " check if the buffer is visible
      exec bufwinnr(a:buffer) . "hide"
    end
  else
    exec bufwinnr(a:buffer) . "close"
  end
endfunction

" Internal: Clear the current neoterm buffer. (Send a <C-l>)
function! neoterm#clear()
  silent call neoterm#exec(["\<c-l>"])
endfunction

" Internal: Kill current process on neoterm. (Send a <C-c>)
function! neoterm#kill()
  silent call neoterm#exec(["\<c-c>"])
endfunction
