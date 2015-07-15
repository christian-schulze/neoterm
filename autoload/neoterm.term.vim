let g:neoterm.term = {}

function! g:neoterm.term.new(id)
  let instance = extend(copy(self), {
        \ "id": a:id,
        \ "name": "neoterm-".a:id
        \ })

  let instance.job_id = termopen([&sh], instance)
  let instance.buffer_id = bufnr("")
  let g:neoterm.open += 1

  return instance
endfunction

function! g:neoterm.term.mappings() dict
  if has_key(g:neoterm, self.id)
    exec "command! -complete=shellcmd Topen".self.id." call g:neoterm.".self.id.".open()"
    exec "command! -complete=shellcmd Tclose".self.id." call g:neoterm.".self.id.".close()"
    exec "command! -complete=shellcmd -nargs=+ T".self.id." call g:neoterm.".self.id.".do(<q-args>)"
  else
    echoe "There is no ".self.id." neoterm."
  end
endfunction

function! g:neoterm.term.open() dict
  let current_window = s:create_split()

  exec "buffer " . self.buffer_id

  silent exec current_window . "wincmd w | set noinsertmode"
endfunction

function! g:neoterm.term.close() dict
  exec bufwinnr(self.buffer_id) . "hide"
endfunction

function! g:neoterm.term.do(command)
  call self.exec([a:command, ''])
endfunction

function! g:neoterm.term.exec(command)
  call jobsend(self.job_id, a:command)
endfunction

function! g:neoterm.term.on_exit()
  call remove(g:neoterm, self.id)
  let g:neoterm.open -= 1
endfunction
