"=============================================================================
" FILE: context_filetype.vim
" AUTHOR: Shougo Matsushita <Shougo.Matsu@gmail.com>
" Last Modified: 19 May 2013.
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

let s:save_cpo = &cpo
set cpo&vim

function! context_filetype#version() "{{{
  return str2nr(printf('%02d%02d', 1, 0))
endfunction"}}}


let s:default_filetypes = {
\	'c': [
\		{'end': '$', 'filetype': 'masm', 'start': '_*asm_*\s\+\h\w*'},
\		{'end': '}', 'filetype': 'masm', 'start': '_*asm_*\s*\%(\n\s*\)\?{'},
\		{'end': ');', 'filetype': 'gas', 'start': '_*asm_*\s*\%(_*volatile_*\s*\)\?('}
\	],
\	'cpp': [
\		{'end': '$', 'filetype': 'masm', 'start': '_*asm_*\s\+\h\w*'},
\		{'end': '}', 'filetype': 'masm', 'start': '_*asm_*\s*\%(\n\s*\)\?{'},
\		{'end': ');', 'filetype': 'gas', 'start': '_*asm_*\s*\%(_*volatile_*\s*\)\?('}
\	],
\	'd': [{'end': '}', 'filetype': 'masm', 'start': 'asm\s*\%(\n\s*\)\?{'}],
\	'eruby': [{'end': '%>', 'filetype': 'ruby', 'start': '<%[=#]\?'}],
\	'help': [{'end': '^<', 'filetype': 'vim', 'start': '^>'}],
\	'html': [
\		{
\			'end': '</script>',
\			'filetype': 'javascript',
\			'start': '<script\%( [^>]*\)\? type="text/javascript"\%( [^>]*\)\?>'
\		},
\		{
\			'end': '</script>',
\			'filetype': 'coffee',
\			'start': '<script\%( [^>]*\)\? type="text/coffeescript"\%( [^>]*\)\?>'
\		},
\		{
\			'end': '</style>',
\			'filetype': 'css',
\			'start': '<style\%( [^>]*\)\? type="text/css"\%( [^>]*\)\?>'
\		}
\	],
\	'int-nyaos': [{'end': '^\1', 'filetype': 'lua', 'start': '\<lua_e\s\+\(["'']\)'}],
\	'nyaos': [{'end': '^\1', 'filetype': 'lua', 'start': '\<lua_e\s\+\(["'']\)'}],
\	'perl6': [{'end': '}', 'filetype': 'pir', 'start': 'Q:PIR\s*{'}],
\	'python': [
\		{'end': '\\\@<!\1\s*)', 'filetype': 'vim', 'start': 'vim.command\s*(\([''"]\)'},
\		{'end': '\\\@<!\1\s*)', 'filetype': 'vim', 'start': 'vim.eval\s*(\([''"]\)'}
\	],
\	'vim': [
\		{'end': '^\1', 'filetype': 'python', 'start': '^\s*py\%[thon\]3\? <<\s*\(\h\w*\)'},
\		{'end': '^\1', 'filetype': 'ruby', 'start': '^\s*rub\%[y\] <<\s*\(\h\w*\)'},
\		{'end': '^\1', 'filetype': 'lua', 'start': '^\s*lua <<\s*\(\h\w*\)'}
\	],
\	'vimshell': [
\		{'end': '\\\@<!\1', 'filetype': 'vim', 'start': 'vexe \([''"]\)'},
\		{'end': '\n', 'filetype': 'vim', 'start': ' :\w*'},
\		{'end': '\n', 'filetype': 'vim', 'start': ' vexe\s\+'}
\	],
\	'xhtml': [
\		{
\			'end': '</script>',
\			'filetype': 'javascript',
\			'start': '<script\%( [^>]*\)\? type="text/javascript"\%( [^>]*\)\?>'
\		},
\		{
\			'end': '</script>',
\			'filetype': 'coffee',
\			'start': '<script\%( [^>]*\)\? type="text/coffeescript"\%( [^>]*\)\?>'
\		},
\		{
\			'end': '</style>',
\			'filetype': 'css',
\			'start': '<style\%( [^>]*\)\? type="text/css"\%( [^>]*\)\?>'
\		}
\	],
\	'markdown': [
\		{"start" : '^\s*```s*\(\h\w*\)', "end" : '^```$', "filetype" : '\1'},
\	],
\}

let g:context_filetype#filetypes = get(g:, "context_filetype#filetypes", {})

function! s:get_filetypes(filetypes)
	return extend(extend(
\		copy(s:default_filetypes), g:context_filetype#filetypes),
\		a:filetypes
\	)
endfunction


" a <= b
function! s:pos_less_equal(a, b)
	return a:a[0] == a:b[0] ? a:a[1] <= a:b[1] : a:a[0] <= a:b[0]
endfunction

let s:null_pos = [0, 0]
let s:null_range = [[0, 0], [0, 0]]


function! s:context_range(start_pattern, end_pattern)
	let start = searchpos(a:start_pattern, "bneW")
	if start == s:null_pos
		return s:null_range
	endif
	let start[1] += 1

	let end_pattern = a:end_pattern
	if end_pattern =~ '\\1'
		let match_list = matchlist(getline(start[0]), a:start_pattern)
		let end_pattern = substitute(end_pattern, '\\1', '\=match_list[1]', 'g')
	endif

	let end_forward = searchpos(end_pattern, 'ncW')
	if end_forward == s:null_pos
		let end_forward = [line('$'), len(getline('$'))+1]
	endi

	let end_backward = searchpos(end_pattern, 'bcnW')
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
endfunction


function! s:is_in(start_pattern, end_pattern, pos)
	let range = s:context_range(a:start_pattern, a:end_pattern)
	if empty(range)
		return 0
	endif

	" start <= pos && pos <= end
	if s:pos_less_equal(range[0], a:pos) && s:pos_less_equal(a:pos, range[1])
		return 1
	endif
	return 0
endfunction

let s:null_context = {
\	"filetype" : "",
\	"range" : s:null_range,
\}

function! s:get_context(filetype, context_filetypes)
	let base_filetype = empty(a:filetype) ? 'nothing' : a:filetype
	let context_filetypes = a:context_filetypes
	let contexts = get(context_filetypes, base_filetype, [])
	if empty(contexts)
		return s:null_context
	endif

	let pos = [line('.'), mode() ==# 'i' ? col('.')-1 : col('.')]
	for context in contexts
		let range = s:context_range(context.start, context.end)

		" start <= pos && pos <= end
		if s:pos_less_equal(range[0], pos) && s:pos_less_equal(pos, range[1])
			let context_filetype = context.filetype
			if context.filetype =~ '\\1'
				let line = getline(searchpos(context.start, 'nbW')[0])
				let match_list = matchlist(line, context.start)
				let context_filetype = substitute(context.filetype, '\\1', '\=match_list[1]', 'g')
			endif
			return { "filetype" : context_filetype, "range" : range }
		endif
	endfor

	return s:null_context
endfunction


function! s:get_nest_impl(filetype, context_filetypes, prev_contexts)
	let context = s:get_context(a:filetype, a:context_filetypes)

	if context.range != s:null_range
\	&& empty(filter(copy(a:prev_contexts), "v:val.filetype == context.filetype"))
		return s:get_nest_impl(
\			context.filetype,
\			a:context_filetypes,
\			add(a:prev_contexts, context)
\		)
	else
		return a:prev_contexts[-1]
	endif
endfunction


function! s:get_nest(filetype, context_filetypes)
	let context = s:get_context(a:filetype, a:context_filetypes)
	return s:get_nest_impl(context.filetype, a:context_filetypes, [context])
endfunction


function! context_filetype#get(...)
	let base_filetype = get(a:, 1, &filetype)
	let filetypes = s:get_filetypes({})
	let context = s:get_nest(base_filetype, filetypes)

	if context.range == s:null_range
		return base_filetype
	else
		return context.filetype
	endif
endfunction


function! context_filetype#get_range(...)
	let base_filetype = get(a:, 1, &filetype)
	let filetypes = s:get_filetypes({})
	let context = s:get_nest(base_filetype, filetypes)
	return context.range
endfunction


function! context_filetype#default_filetypes()
	return deepcopy(s:default_filetypes)
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo

" vim: foldmethod=marker
