if !has("nvim")
  finish
endif

let g:neoterm = {
      \ 'last_id': 0,
      \ 'open': 0,
      \ 'last': function('neoterm#last')
      \ }

aug neoterm_setup
  au!
  au TermOpen term://*:NEOTERM-.* setlocal nonumber norelativenumber
aug END

command! -complete=shellcmd Tnew call neoterm#new()
command! -complete=shellcmd Topen call neoterm#open()
command! -complete=shellcmd Tclose call neoterm#close()
command! -complete=shellcmd -nargs=+ T call neoterm#do(<q-args>)
