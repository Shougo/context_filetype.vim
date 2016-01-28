"=============================================================================
" FILE: context_filetype.vim
" AUTHOR: Shougo Matsushita <Shougo.Matsu@gmail.com>
" Last Modified: 31 Jan 2014.
" License: MIT license  {{{
"     Permission is hereby granted, free of charge, to any person obtaining
"     a copy of this software and associated documentation files (the
"     "Software"), to deal in the Software without restriction, including
"     without limitation the rights to use, copy, modify, merge, publish,
"     distribute, sublicense, and/or sell copies of the Software, and to
"     permit persons to whom the Software is furnished to do so, subject to
"     the following conditions:
"
"     The above copyright notice and this permission notice shall be included
"     in all copies or substantial portions of the Software.
"
"     THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
"     OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
"     MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
"     IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
"     CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
"     TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
"     SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
" }}}
"=============================================================================
scriptencoding utf-8

let s:save_cpo = &cpo
set cpo&vim

let g:context_filetype#filetypes = get(g:,
      \ 'context_filetype#filetypes', {})

let g:context_filetype#ignore_composite_filetypes = get(g:,
      \ 'context_filetype#ignore_composite_filetypes', {})

let g:context_filetype#same_filetypes = get(g:,
      \ 'context_filetype#same_filetypes', {})

let g:context_filetype#search_offset = get(g:,
      \ 'context_filetype#search_offset', 3000)

function! context_filetype#version() "{{{
  return str2nr(printf('%02d%02d', 1, 0))
endfunction"}}}


function! context_filetype#get(...) "{{{
  let base_filetype = get(a:, 1, &filetype)
  let filetypes = s:get_filetypes({})
  let context = s:get_nest(base_filetype, filetypes)
  if context.range == s:null_range
    let context.filetype = base_filetype
  endif
  return context
endfunction"}}}


function! context_filetype#get_filetype(...) "{{{
  let base_filetype = get(a:, 1, &filetype)
  return context_filetype#get(base_filetype).filetype
endfunction"}}}

function! context_filetype#get_filetypes(...) "{{{
  let filetype = call('context_filetype#get_filetype', a:000)

  let filetypes = [filetype]
  if filetype =~ '\.'
    if has_key(g:context_filetype#ignore_composite_filetypes, filetype)
      let filetypes =
            \ [g:context_filetype#ignore_composite_filetypes[filetype]]
    else
      " Set composite filetype.
      let filetypes += split(filetype, '\.')
    endif
  endif

  for ft in copy(filetypes)
    let filetypes += s:get_same_filetypes(ft)
  endfor

  if len(filetypes) > 1
    let filetypes = s:uniq(filetypes)
  endif

  return filetypes
endfunction"}}}


function! context_filetype#get_range(...) "{{{
  let base_filetype = get(a:, 1, &filetype)
  return context_filetype#get(base_filetype).range
endfunction"}}}


function! context_filetype#default_filetypes() "{{{
  return copy(s:default_filetypes)
endfunction"}}}


" s:default_filetypes {{{
let s:default_filetypes = {
      \ 'c': [
      \   {
      \    'start': '_*asm_*\s\+\h\w*',
      \    'end': '$', 'filetype': 'masm',
      \   },
      \   {
      \    'start': '_*asm_*\s*\%(\n\s*\)\?{',
      \    'end': '}', 'filetype': 'masm',
      \   },
      \   {
      \    'start': '_*asm_*\s*\%(_*volatile_*\s*\)\?(',
      \    'end': ');', 'filetype': 'gas',
      \   },
      \ ],
      \ 'cpp': [
      \   {
      \    'start': '_*asm_*\s\+\h\w*',
      \    'end': '$', 'filetype': 'masm',
      \   },
      \   {
      \    'start': '_*asm_*\s*\%(\n\s*\)\?{',
      \    'end': '}', 'filetype': 'masm',
      \   },
      \   {
      \    'start': '_*asm_*\s*\%(_*volatile_*\s*\)\?(',
      \    'end': ');', 'filetype': 'gas',
      \   },
      \ ],
      \ 'd': [
      \   {
      \    'start': 'asm\s*\%(\n\s*\)\?{',
      \    'end': '}', 'filetype': 'masm',
      \   },
      \ ],
      \ 'eruby': [
      \   {
      \    'start': '<%[=#]\?',
      \    'end': '%>', 'filetype': 'ruby',
      \   },
      \ ],
      \ 'help': [
      \   {
      \    'start': '^>\|\s>$',
      \    'end': '^<\|^\S', 'filetype': 'vim',
      \   },
      \ ],
      \ 'html': [
      \   {
      \    'start':
      \     '<script\%( [^>]*\)\? type="text/javascript"\%( [^>]*\)\?>',
      \    'end': '</script>', 'filetype': 'javascript',
      \   },
      \   {
      \    'start':
      \     '<script\%( [^>]*\)\? type="text/coffeescript"\%( [^>]*\)\?>',
      \    'end': '</script>', 'filetype': 'coffee',
      \   },
      \   {
      \    'start': '<style\%( [^>]*\)\? type="text/css"\%( [^>]*\)\?>',
      \    'end': '</style>', 'filetype': 'css',
      \   },
      \   {
      \    'start':
      \     '<script\%( [^>]*\)\?>',
      \    'end': '</script>', 'filetype': 'javascript',
      \   },
      \ ],
      \ 'int-nyaos': [
      \   {
      \    'start': '\<lua_e\s\+\(["'']\)',
      \    'end': '\1\@<!\1\1\@!', 'filetype': 'lua',
      \   },
      \ ],
      \ 'lua': [
      \   {
      \    'start': 'vim.command\s*(\([''"]\)',
      \    'end': '\\\@<!\1', 'filetype': 'vim',
      \   },
      \   {
      \    'start': 'vim.eval\s*(\([''"]\)',
      \    'end': '\\\@<!\1', 'filetype': 'vim',
      \   },
      \ ],
      \ 'nyaos': [
      \   {
      \    'start': '\<lua_e\s\+\(["'']\)',
      \    'end': '\1\@<!\1\1\@!', 'filetype': 'lua',
      \   },
      \ ],
      \ 'perl6': [
      \   {
      \    'start': 'Q:PIR\s*{',
      \    'end': '}', 'filetype': 'pir',
      \   },
      \ ],
      \ 'python': [
      \   {
      \    'start': 'vim.command\s*(\([''"]\)',
      \    'end': '\\\@<!\1', 'filetype': 'vim',
      \   },
      \   {
      \    'start': 'vim.eval\s*(\([''"]\)',
      \    'end': '\\\@<!\1', 'filetype': 'vim',
      \   },
      \   {
      \    'start': 'vim.call\s*(\([''"]\)',
      \    'end': '\\\@<!\1', 'filetype': 'vim',
      \   },
      \ ],
      \ 'vim': [
      \   {
      \    'start': '^\s*py\%[thon\]3\? <<\s*\(\h\w*\)',
      \    'end': '^\1', 'filetype': 'python',
      \   },
      \   {
      \    'start': '^\s*rub\%[y\] <<\s*\(\h\w*\)',
      \    'end': '^\1', 'filetype': 'ruby',
      \   },
      \   {
      \    'start': '^\s*lua <<\s*\(\h\w*\)',
      \    'end': '^\1', 'filetype': 'lua',
      \   },
      \   {
      \    'start': '^\s*lua ',
      \    'end': '\n\|\s\+|', 'filetype': 'lua',
      \   },
      \ ],
      \ 'vimshell': [
      \   {
      \    'start': 'vexe \([''"]\)',
      \    'end': '\\\@<!\1', 'filetype': 'vim',
      \   },
      \   {
      \    'start': ' :\w*',
      \    'end': '\n', 'filetype': 'vim',
      \   },
      \   {
      \    'start': ' vexe\s\+',
      \    'end': '\n', 'filetype': 'vim',
      \   },
      \ ],
      \ 'xhtml': [
      \   {
      \    'start':
      \     '<script\%( [^>]*\)\? type="text/javascript"\%( [^>]*\)\?>',
      \    'end': '</script>', 'filetype': 'javascript',
      \   },
      \   {
      \    'start':
      \     '<script\%( [^>]*\)\? type="text/coffeescript"\%( [^>]*\)\?>',
      \    'end': '</script>', 'filetype': 'coffee',
      \   },
      \   {
      \    'start': '<style\%( [^>]*\)\? type="text/css"\%( [^>]*\)\?>',
      \    'end': '</style>', 'filetype': 'css',
      \   },
      \ ],
      \ 'markdown': [
      \   {
      \    'start' : '^\s*```\s*\(\h\w*\)',
      \    'end' : '^\s*```$', 'filetype' : '\1',
      \   },
      \ ],
      \ 'haml': [
      \   {
      \    'start' : '^\s*-',
      \    'end' : '$', 'filetype' : 'ruby',
      \   },
      \   {
      \    'start' : '^\s*\w*=',
      \    'end' : '$', 'filetype' : 'ruby',
      \   },
      \   {
      \    'start' : '^:javascript$',
      \    'end' : '^\S', 'filetype' : 'javascript',
      \   },
      \   {
      \    'start' : '^:css$',
      \    'end' : '^\S', 'filetype' : 'css',
      \   },
      \ ],
      \ 'jade': [
      \   {
      \    'start' : '^\(\s*\)script\.\s*$',
      \    'end' : '^\%(\1\s\|\s*$\)\@!',
      \    'filetype' : 'javascript',
      \   },
      \   {
      \    'start' : '^\(\s*\):coffeescript\s*$',
      \    'end' : '^\%(\1\s\|\s*$\)\@!',
      \    'filetype' : 'coffee',
      \   },
      \   {
      \    'start' : '^\(\s*\):\(\h\w*\)\s*$',
      \    'end' : '^\%(\1\s\|\s*$\)\@!',
      \    'filetype' : '\2',
      \   },
      \ ],
\}"}}}


function! s:get_filetypes(filetypes) "{{{
  return extend(extend(
        \ copy(s:default_filetypes), g:context_filetype#filetypes),
        \ a:filetypes
        \)
endfunction"}}}

" s:default_same_filetypes {{{
let s:default_same_filetypes = {
      \ 'cpp': 'c',
      \ 'erb': 'ruby,html,xhtml',
      \ 'html': 'xhtml,css,stylus,less',
      \ 'xml': 'xhtml',
      \ 'xhtml': 'html,xml,css,stylus,less',
      \ 'css': 'scss',
      \ 'scss': 'css',
      \ 'stylus': 'css',
      \ 'less': 'css',
      \ 'help': 'vim',
      \ 'tex': 'bib,plaintex',
      \ 'plaintex': 'bib,tex',
      \ 'lingr-say': 'lingr-messages,lingr-members',
      \ 'J6uil_say': 'J6uil',
      \ 'vimconsole': 'vim',
      \
      \ 'int-irb': 'ruby',
      \ 'int-ghci': 'haskell',
      \ 'int-hugs': 'haskell',
      \ 'int-python': 'python',
      \ 'int-python3': 'python',
      \ 'int-ipython': 'python',
      \ 'int-ipython3': 'python',
      \ 'int-gosh': 'scheme',
      \ 'int-clisp': 'lisp',
      \ 'int-erl': 'erlang',
      \ 'int-zsh': 'zsh',
      \ 'int-bash': 'bash',
      \ 'int-sh': 'sh',
      \ 'int-cmdproxy': 'dosbatch',
      \ 'int-powershell': 'powershell',
      \ 'int-perlsh': 'perl',
      \ 'int-perl6': 'perl6',
      \ 'int-ocaml': 'ocaml',
      \ 'int-clj': 'clojure',
      \ 'int-lein': 'clojure',
      \ 'int-sml': 'sml',
      \ 'int-smlsharp': 'sml',
      \ 'int-js': 'javascript',
      \ 'int-kjs': 'javascript',
      \ 'int-rhino': 'javascript',
      \ 'int-coffee': 'coffee',
      \ 'int-gdb': 'gdb',
      \ 'int-scala': 'scala',
      \ 'int-nyaos': 'nyaos',
      \ 'int-php': 'php',
\}"}}}


function! s:get_same_filetypes(filetype) "{{{
  let same_filetypes = extend(copy(s:default_same_filetypes),
        \ g:context_filetype#same_filetypes)
  return split(get(same_filetypes, a:filetype,
          \ get(same_filetypes, '_', '')), ',')
endfunction"}}}


function! s:stopline_forward() "{{{
  let stopline_forward = line('.') + g:context_filetype#search_offset
  return (stopline_forward > line('$')) ? line('$') : stopline_forward
endfunction"}}}


function! s:stopline_back() "{{{
  let stopline_back = line('.') - g:context_filetype#search_offset
  return (stopline_back <= 1) ? 1 : stopline_back
endfunction"}}}


" a <= b "{{{
function! s:pos_less_equal(a, b)
  return a:a[0] == a:b[0] ? a:a[1] <= a:b[1] : a:a[0] <= a:b[0]
endfunction"}}}


function! s:is_in(start, end, pos) "{{{
  " start <= pos && pos <= end
  return s:pos_less_equal(a:start, a:pos) && s:pos_less_equal(a:pos, a:end)
endfunction"}}}


function! s:file_range() "{{{
  return [[1, 1], [line('$'), len(getline('$'))+1]]
endfunction"}}}

function! s:replace_submatch(pattern, match_list) "{{{
  let num_list = matchlist(a:pattern, '\\\zs\d\+\ze')
  let pattern = a:pattern
  for num in num_list
    if num
      let pattern = substitute(pattern, '\\'.num, a:match_list[num], 'g')
    endif
  endfor
  return pattern
endfunction "}}}


let s:null_pos = [0, 0]
let s:null_range = [[0, 0], [0, 0]]


function! s:search_range(start_pattern, end_pattern) "{{{
  let stopline_forward = s:stopline_forward()
  let stopline_back    = s:stopline_back()

  let start = searchpos(a:start_pattern, 'bnceW', stopline_back)
  if start == s:null_pos
    return s:null_range
  endif
  let start[1] += 1

  let end_pattern = a:end_pattern
  if end_pattern =~ '\\\d\+'
    let match_list = matchlist(getline(start[0]), a:start_pattern)
    let end_pattern = s:replace_submatch(end_pattern, match_list)
  endif

  let end_forward = searchpos(end_pattern, 'ncW', stopline_forward)
  if end_forward == s:null_pos
    let end_forward = [line('$'), len(getline('$'))+1]
  endi

  let end_backward = searchpos(end_pattern, 'bnW', stopline_back)
  if s:pos_less_equal(start, end_backward)
    return s:null_range
  endif
  let end_forward[1] -= 1

  if start[1] >= strdisplaywidth(getline(start[0]))
    let start[0] += 1
    let start[1] = 1
  endif

  if end_forward[1] <= 1
    let end_forward[0] -= 1
    let len = strdisplaywidth(getline(end_forward[0]))
    let len = len ? len : 1
    let end_forward[1] = len
  endif

  return [start, end_forward]
endfunction"}}}


let s:null_context = {
\ 'filetype' : '',
\ 'range' : s:null_range,
\}


function! s:get_context(filetype, context_filetypes, search_range) "{{{
  let base_filetype = empty(a:filetype) ? 'nothing' : a:filetype
  let context_filetypes = get(a:context_filetypes, base_filetype, [])
  if empty(context_filetypes)
    return s:null_context
  endif

  let pos = [line('.'), col('.')]

  for context in context_filetypes
    let range = s:search_range(context.start, context.end)

    " insert 時にカーソル座標がずれるのでそれの対応
    let start = range[0]
    let end   = [range[1][0], (mode() ==# 'i') ? range[1][1]+1 : range[1][1]]

    " start <= pos && pos <= end
    " search_range[0] <= start && start <= search_range[1]
    " search_range[0] <= end   && end   <= search_range[1]
    if range != s:null_range
          \  && s:is_in(start, end, pos)
          \  && s:is_in(a:search_range[0], a:search_range[1], range[0])
          \  && s:is_in(a:search_range[0], a:search_range[1], range[1])
      let context_filetype = context.filetype
      if context.filetype =~ '\\\d\+'
        let stopline_back = s:stopline_back()
        let line = getline(
              \ searchpos(context.start, 'nbW', stopline_back)[0]
              \ )
        let match_list = matchlist(line, context.start)
        let context_filetype = s:replace_submatch(context.filetype, match_list)
      endif
      return { "filetype" : context_filetype, "range" : range }
    endif
  endfor

  return s:null_context
endfunction"}}}


function! s:get_nest_impl(filetype, context_filetypes, prev_context) "{{{
  let context = s:get_context(a:filetype,
        \ a:context_filetypes, a:prev_context.range)
  if context.range != s:null_range && context.filetype !=# a:filetype
    return s:get_nest_impl(context.filetype, a:context_filetypes, context)
  else
    return a:prev_context
  endif
endfunction"}}}


function! s:get_nest(filetype, context_filetypes) "{{{
  let context = s:get_context(a:filetype, a:context_filetypes, s:file_range())
  return s:get_nest_impl(context.filetype, a:context_filetypes, context)
endfunction"}}}

function! s:uniq(list) "{{{
  let dict = {}
  for item in a:list
    if !has_key(dict, item)
      let dict[item] = item
    endif
  endfor

  return values(dict)
endfunction"}}}


let &cpo = s:save_cpo
unlet s:save_cpo

" vim: set foldmethod=marker tabstop=2 expandtab:
