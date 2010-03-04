" YankRingSync - Synchronize register with YankRing history before putting
" Version: 0.0.1
" Copyright 2010, ISHIHARA Masaki <http://m4i.jp/>
" License: MIT license  {{{
"     Permission is hereby granted, free of charge, to any person obtaining
"     a copy of this software and associated documentation files (the
"     "Software"), to deal in the Software without restriction, including
"     without limitation the rights to use, copy, modify, merge, publish,
"     distribute, sublicense, and/or sell copies of the Software, and to
"     permit persons to whom the Software is furnished to do so, subject to
"     the following conditions:
"
"     The above copyright notice and this permission notice shall be
"     included in all copies or substantial portions of the Software.
"
"     THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
"     EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
"     MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
"     NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
"     LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
"     OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
"     WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
" }}}

if exists('g:loaded_yankringsync')
  finish
endif




if !exists('loaded_yankring')
  echomsg 'YankRingSync: You need yankring.vim'
  finish
endif

if loaded_yankring < 100
  echomsg 'YankRingSync: You need at least yankring.vim 10.0'
  finish
endif


function! s:GetScriptID(path)
  let scriptnames = ''
  redir => scriptnames
  silent scriptnames
  redir END
  let paths   = resolve(a:path) . '\|' . simplify(a:path)
  let pattern = '\zs\d\+\ze: \(' . escape(paths, '.') . '\)\n'
  return matchstr(scriptnames, pattern) + 0
endfunction

function! s:GetLocalFunctionName(name, path)
  let script_id = s:GetScriptID(a:path)
  return script_id ? ('<SNR>' . script_id . '_' . a:name) : ''
endfunction

function! s:GetLocalFunction(name, path)
  return function(s:GetLocalFunctionName(a:name, a:path))
endfunction

function! s:SearchInRuntimePath(path)
  for runtimepath in split(substitute(&runtimepath, '\', '/', 'g'), ',')
    let path = runtimepath . '/' . a:path
    if filereadable(path)
      return path
    endif
  endfor
  return ''
endfunction


if !exists('g:yankringsync_yankring_path')
    let g:yankringsync_yankring_path = 'plugin/yankring.vim'
endif

let yankring_path = s:SearchInRuntimePath(g:yankringsync_yankring_path)
if !strlen(yankring_path)
  unlet yankring_path
  echomsg 'YankRingSync: cannot find "' . g:yankringsync_yankring_path . '"'
  finish
endif

let s:YRSetNumberedReg = s:GetLocalFunction('YRSetNumberedReg', yankring_path)
let s:YRPasteName      = s:GetLocalFunctionName('YRPaste', yankring_path)
let s:YRHistoryRead    = s:GetLocalFunction('YRHistoryRead', yankring_path)
unlet yankring_path

function! s:YRPasteWithHistoryRead(...)
  call s:YRHistoryRead()
  return call(s:YRPasteName, a:000)
endfunction

command! -count -register -nargs=* YRPasteWithHistoryRead
      \ call s:YRPasteWithHistoryRead(0,1,<args>)

augroup YankRingSync
  autocmd!
  " for the first time
  autocmd VimEnter * :call s:YRSetNumberedReg()
augroup END


if g:yankring_paste_n_bkey != ''
  exec 'nnoremap <silent>'.g:yankring_paste_n_bkey." :<C-U>YRPasteWithHistoryRead 'P'<CR>"
  if g:yankring_paste_using_g == 1
    exec 'nnoremap <silent> g'.g:yankring_paste_n_bkey." :<C-U>YRPasteWithHistoryRead 'gP'<CR>"
  endif
endif
if g:yankring_paste_n_akey != ''
  exec 'nnoremap <silent>'.g:yankring_paste_n_akey." :<C-U>YRPasteWithHistoryRead 'p'<CR>"
  if g:yankring_paste_using_g == 1
    exec 'nnoremap <silent> g'.g:yankring_paste_n_akey." :<C-U>YRPasteWithHistoryRead 'gp'<CR>"
  endif
endif
if g:yankring_paste_v_bkey != ''
  exec 'xnoremap <silent>'.g:yankring_paste_v_bkey." :<C-U>YRPasteWithHistoryRead 'P', 'v'<CR>"
endif
if g:yankring_paste_v_akey != ''
  exec 'xnoremap <silent>'.g:yankring_paste_v_akey." :<C-U>YRPasteWithHistoryRead 'p', 'v'<CR>"
endif




let g:loaded_yankringsync = 1

" __END__
" vim: foldmethod=marker
