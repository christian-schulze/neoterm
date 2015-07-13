function! s:next_neoterm_id()
  let g:neoterm.last_id += 1
  return g:neoterm.last_id
endfunction

function! neoterm#new()
  new
  let instance = s:neoterm.new(s:next_neoterm_id())
  let g:neoterm[instance.id] = instance

  call instance.mappings()
endfunction

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let s:neoterm = {}

function! s:neoterm.new(id)
  let instance = extend(copy(self), {
        \ 'id': a:id,
        \ 'name': 'neoterm-'.a:id
        \ })

  let instance.job_id = termopen([&sh], instance)
  let instance.buffer_id = bufnr('')

  return instance
endfunction

function! s:neoterm.mappings() dict
  if has_key(g:neoterm, self.id)
    exec 'command! -complete=shellcmd Topen'.self.id.' call g:neoterm.'.self.id.'.open()'
    exec 'command! -complete=shellcmd Tclose'.self.id.' call g:neoterm.'.self.id.'.close()'
    exec 'command! -complete=shellcmd -nargs=+ T'.self.id.' call g:neoterm.'.self.id.'.exec(<q-args>)'
  else
    echoe 'There is no '.self.id.' neoterm.'
  end
endfunction

function! s:neoterm.open() dict
  new
  exec 'buffer ' . self.buffer_id
endfunction

function! s:neoterm.close() dict
  exec bufwinnr(self.buffer_id) . 'hide'
endfunction

function! s:neoterm.exec(command)
  call jobsend(self.job_id, [a:command, ''])
endfunction

function! s:neoterm.on_exit()
  call remove(g:neoterm, self.id)
endfunction
