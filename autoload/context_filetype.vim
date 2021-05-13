"=============================================================================
" FILE: context_filetype.vim
" AUTHOR: Shougo Matsushita <Shougo.Matsu at gmail.com>
" License: MIT license
"=============================================================================

let g:context_filetype#filetypes = get(g:,
      \ 'context_filetype#filetypes', {})

let g:context_filetype#ignore_composite_filetypes = get(g:,
      \ 'context_filetype#ignore_composite_filetypes', {})

let g:context_filetype#same_filetypes = get(g:,
      \ 'context_filetype#same_filetypes', {})

let g:context_filetype#ignore_patterns = get(g:,
      \ 'context_filetype#ignore_patterns', {})

let g:context_filetype#search_offset = get(g:,
      \ 'context_filetype#search_offset', 200)

function! context_filetype#version() abort
  return str2nr(printf('%02d%02d', 1, 0))
endfunction


function! context_filetype#get(...) abort
  let base_filetype = get(a:, 1, &filetype)
  let filetypes = context_filetype#filetypes()
  let context = s:get_nest(base_filetype, filetypes)
  if context.range == s:null_range && !has_key(context, 'synname')
    let context.filetype = base_filetype
  endif
  return context
endfunction


function! context_filetype#get_filetype(...) abort
  let base_filetype = get(a:, 1, &filetype)
  return context_filetype#get(base_filetype).filetype
endfunction

function! context_filetype#get_filetypes(...) abort
  let filetype = call('context_filetype#get_filetype', a:000)

  let filetypes = [filetype]
  if filetype =~# '\.'
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
endfunction

function! context_filetype#get_same_filetypes(...) abort
  let filetype = call('context_filetype#get_filetype', a:000)

  let filetypes = []
  for ft in context_filetype#get_filetypes(filetype)
    let filetypes += s:get_same_filetypes(ft)
  endfor

  if len(filetypes) > 1
    let filetypes = s:uniq(filetypes)
  endif

  return filetypes
endfunction


function! context_filetype#get_range(...) abort
  let base_filetype = get(a:, 1, &filetype)
  return context_filetype#get(base_filetype).range
endfunction

function! context_filetype#default_filetypes() abort
  return deepcopy(g:context_filetype#defaults#_filetypes)
endfunction

function! context_filetype#filetypes() abort
  if exists('b:context_filetype_filetypes')
    return deepcopy(b:context_filetype_filetypes)
  endif
  return extend(deepcopy(g:context_filetype#defaults#_filetypes),
        \ deepcopy(g:context_filetype#filetypes))
endfunction

function! context_filetype#ignore_patterns() abort
  if exists('b:context_filetype_ignore_patterns')
    return deepcopy(b:context_filetype_ignore_patterns)
  endif
  return extend(deepcopy(g:context_filetype#defaults#_ignore_patterns),
        \ deepcopy(g:context_filetype#ignore_patterns))
endfunction

function! s:get_same_filetypes(filetype) abort
  let same_filetypes = extend(
        \ copy(g:context_filetype#defaults#_same_filetypes),
        \ g:context_filetype#same_filetypes
        \ )
  return split(get(same_filetypes, a:filetype,
          \ get(same_filetypes, '_', '')), ',')
endfunction


function! s:stopline_forward() abort
  let stopline_forward = line('.') + g:context_filetype#search_offset
  return (stopline_forward > line('$')) ? line('$') : stopline_forward
endfunction


function! s:stopline_back() abort
  let stopline_back = line('.') - g:context_filetype#search_offset
  return (stopline_back <= 1) ? 1 : stopline_back
endfunction


" a <= b
function! s:pos_less_equal(a, b) abort
  return a:a[0] == a:b[0] ? a:a[1] <= a:b[1] : a:a[0] <= a:b[0]
endfunction


function! s:is_in(start, end, pos) abort
  " start <= pos && pos <= end
  return s:pos_less_equal(a:start, a:pos) && s:pos_less_equal(a:pos, a:end)
endfunction


function! s:file_range() abort
  return [[1, 1], [line('$'), len(getline('$'))+1]]
endfunction

function! s:replace_submatch(pattern, match_list) abort
  return substitute(a:pattern, '\\\@>\(\d\)',
      \ {m -> a:match_list[m[1]]}, 'g')
endfunction

function! s:replace_submatch_pattern(pattern, match_list) abort
  let pattern = ''
  let backref_end_prev = 0
  let backref_start = match(a:pattern, '\\\@>\d')
  let backref_end = backref_start + 2
  let magic = '\m'
  let magic_start = match(a:pattern, '\\\@>[vmMV]')
  while 0 <= backref_start
    while 0 <= magic_start && magic_start <= backref_end
      let magic = a:pattern[magic_start : magic_start + 1]
      let magic_start = match(a:pattern, '\\\@>[vmMV]', magic_start + 2)
      if magic_start == backref_end
        let backref_end += 2
      endif
    endwhile
    if backref_start != 0
      let pattern .= a:pattern[backref_end_prev : backref_start - 1]
    endif
    let pattern .= '\V'
        \ . escape(a:match_list[a:pattern[backref_start + 1]], '\')
        \ . magic
    let backref_end_prev = backref_end
    let backref_start = match(a:pattern, '\\\@>\d', backref_end_prev)
    let backref_end = backref_start + 2
  endwhile
  return pattern . a:pattern[backref_end_prev : -1]
endfunction


let s:null_pos = [0, 0]
let s:null_range = [[0, 0], [0, 0]]


function! s:search_range(start_pattern, end_pattern, ignore_pattern) abort
  let stopline_forward = s:stopline_forward()
  let stopline_back    = s:stopline_back()

  let cur_text =
        \ (mode() ==# 'i' ? (col('.')-1) : col('.')) >= len(getline('.')) ?
        \      getline('.') :
        \      matchstr(getline('.'),
        \         '^.*\%' . (mode() ==# 'i' ? col('.') : col('.') - 1)
        \         . 'c' . (mode() ==# 'i' ? '' : '.'))
  let start_pattern = a:ignore_pattern . a:start_pattern
  let curline_pattern = start_pattern . '\ze.\{-}$'
  if cur_text =~# curline_pattern
    let start = [line('.'), matchend(cur_text, curline_pattern)]
  else
    let start = searchpos(start_pattern, 'bnceW', stopline_back)
  endif
  if start == s:null_pos
    return s:null_range
  endif
  let start[1] += 1

  let end_pattern = a:end_pattern
  if end_pattern =~# '\\\@>\d'
    let lines = getline(start[0], line('.'))
    let match_list = matchlist(join(lines, "\n"), start_pattern)
    let end_pattern = s:replace_submatch_pattern(end_pattern, match_list)
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

  if mode() !=# 'i' && start[1] >= strdisplaywidth(getline(start[0]))
    let start[0] += 1
    let start[1] = 1
  endif

  if end_forward[1] <= 1
    let end_forward[0] -= 1
    let len = len(getline(end_forward[0]))
    let len = len ? len : 1
    let end_forward[1] = len
  endif

  return [start, end_forward]
endfunction


let s:null_context = {
\ 'filetype' : '',
\ 'range' : s:null_range,
\}


function! s:get_context(filetype, context_filetypes, search_range) abort
  let base_filetype = empty(a:filetype) ? 'nothing' : a:filetype
  let context_filetypes = get(a:context_filetypes, base_filetype, [])
  if empty(context_filetypes)
    return s:null_context
  endif

  let pos = [line('.'), col('.')]

  let ignore_patterns = get(context_filetype#ignore_patterns(),
        \ base_filetype, [])

  let ignore_pattern = empty(ignore_patterns) ? '' :
        \ '\%(' . join(ignore_patterns, '|') . '\)\@<!'

  for context in context_filetypes
    " Todo: neovim treesitter support
    if has_key(context, 'synname_pattern')
      for id in synstack(line('.'), col('.'))
        let synname = synIDattr(id, 'name')
        if synname =~# context.synname_pattern
          return {
                \ 'filetype' : context.filetype,
                \ 'range': s:null_range, 'synname': synname
                \ }
        endif
      endfor
      continue
    endif

    let range = s:search_range(context.start, context.end, ignore_pattern)

    " Set cursor position
    let start = range[0]
    let end   = [range[1][0], (mode() ==# 'i') ? range[1][1]+1 : range[1][1]]

    " start <= pos && pos <= end
    " search_range[0] <= start && start <= search_range[1]
    " search_range[0] <= end   && end   <= search_range[1]
    if range != s:null_range
          \  && s:is_in(start, end, pos)
          \  && s:is_in(a:search_range[0], a:search_range[1], range[0])
          \  && s:is_in(a:search_range[0], a:search_range[1], range[1])
      let context_filetype = get(context, 'filetype', a:filetype)
      if context_filetype =~# '\\\@>\d'
        let stopline_back = s:stopline_back()
        let lines = getline(
              \ searchpos(context.start, 'nbW', stopline_back)[0],
              \ line('.')
              \ )
        let match_list = matchlist(join(lines, "\n"), context.start)
        let context_filetype = s:replace_submatch(context_filetype, match_list)
      endif
      return {'filetype' : context_filetype, 'range' : range}
    endif
  endfor

  return s:null_context
endfunction


function! s:get_nest_impl(filetype, context_filetypes, prev_context) abort
  let context = s:get_context(a:filetype,
        \ a:context_filetypes, a:prev_context.range)
  if context.range != s:null_range && context.filetype !=# a:filetype
    return s:get_nest_impl(context.filetype, a:context_filetypes, context)
  else
    return a:prev_context
  endif
endfunction


function! s:get_nest(filetype, context_filetypes) abort
  let context = s:get_context(
        \ a:filetype, a:context_filetypes, s:file_range())
  return s:get_nest_impl(context.filetype, a:context_filetypes, context)
endfunction

function! s:uniq(list) abort
  let dict = {}
  for item in a:list
    if item !=# '' && !has_key(dict, item)
      let dict[item] = item
    endif
  endfor

  return values(dict)
endfunction
