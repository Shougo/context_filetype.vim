"=============================================================================
" FILE: defaultsvim
" AUTHOR: Shougo Matsushita <Shougo.Matsu at gmail.com>
" License: MIT license
"=============================================================================

let g:context_filetype#defaults#_filetypes = {
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
      \    'end': '^<\|^\S\|^$', 'filetype': 'vim',
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
      \    'start':
      \     '<script\%( [^>]*\)\?>',
      \    'end': '</script>', 'filetype': 'javascript',
      \   },
      \   {
      \    'start':
      \     '<style\%( [^>]*\)\?>',
      \    'end': '</style>', 'filetype': 'css',
      \   },
      \   {
      \    'start':
      \     '<[^>]\+ style=\([''"]\)',
      \    'end': '\1', 'filetype': 'css',
      \   },
      \ ],
      \ 'vue': [
      \   {
      \    'start':
      \     '<template\%( [^>]*\)\? \%(lang="\%(\(\h\w*\)\)"\)\%( [^>]*\)\?>',
      \    'end': '</template>', 'filetype': '\1',
      \   },
      \   {
      \    'start':
      \     '<template\%( [^>]*\)\?>',
      \    'end': '</template>', 'filetype': 'html',
      \   },
      \   {
      \    'start':
      \     '<script\%( [^>]*\)\? \%(ts\|lang="\%(ts\|typescript\)"\)\%( [^>]*\)\?>',
      \    'end': '</script>', 'filetype': 'typescript',
      \   },
      \   {
      \    'start':
      \     '<script\%( [^>]*\)\? \%(lang="\%(\(\h\w*\)\)"\)\%( [^>]*\)\?>',
      \    'end': '</script>', 'filetype': '\1',
      \   },
      \   {
      \    'start':
      \     '<script\%( [^>]*\)\?>',
      \    'end': '</script>', 'filetype': 'javascript',
      \   },
      \   {
      \    'start':
      \     '<style\%( [^>]*\)\? \%(lang="\%(\(\h\w*\)\)"\)\%( [^>]*\)\?>',
      \    'end': '</style>', 'filetype': '\1',
      \   },
      \   {
      \    'start':
      \     '<style\%( [^>]*\)\?>',
      \    'end': '</style>', 'filetype': 'css',
      \   },
      \   {
      \    'start':
      \     '<\(\h\w*\)>',
      \    'end': '</\1>', 'filetype': 'vue-\1',
      \   },
      \   {
      \    'start':
      \     '<\(\h\w*\) \%(lang="\%(\(\h\w*\)\)"\)\%( [^>]*\)\?>',
      \    'end': '</\1>', 'filetype': '\2',
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
      \    'start': '^\s*pe\%[rl\] <<\s*\(\h\w*\)',
      \    'end': '^\1', 'filetype': 'perl',
      \   },
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
      \ 'vimperator': [
      \   {
      \    'start': '^\s*\%(javascript\|js\)\s\+<<\s*\(\h\w*\)',
      \    'end': '^\1', 'filetype': 'javascript',
      \   }
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
      \   {
      \    'start' : '\%^-\{3,}.*$',
      \    'end' : '\_^-\{3,}.*$', 'filetype' : 'yaml'
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
      \ 'toml': [
      \   {
      \    'start': '\<\%(hook_\%('.
      \             'add\|source\|post_source\|post_update'.
      \             '\)\|[_a-z]\+'.
      \             '\)\s*=\s*\('."'''".'\|"""\)',
      \    'end': '\1', 'filetype': 'vim',
      \   },
      \ ],
      \ 'go': [
      \   {
      \    'start': '^\s*\%(//\s*\)\?#\s*include\s\+',
      \    'end': '$', 'filetype': 'c',
      \   },
      \ ],
      \ 'asciidoc': [
      \   {
      \    'start' : '^\[source\%(%[^,]*\)\?,\(\h\w*\)\(,.*\)\?\]\s*\n----\s*\n',
      \    'end' : '^----\s*$', 'filetype' : '\1',
      \   },
      \   {
      \    'start' : '^\[source\%(%[^,]*\)\?,\(\h\w*\)\(,.*\)\?\]\s*\n',
      \    'end' : '^$', 'filetype' : '\1',
      \   },
      \ ],
      \ 'review': [
      \   {
      \    'start': '^//list\[[^]]\+\]\[[^]]\+\]\[\([^]]\+\)\]{',
      \    'end': '^//}', 'filetype' : '\1',
      \   },
      \ ],
      \ 'javascript': [
      \   {
      \    'synname_pattern': '^jsx',
      \    'filetype' : 'jsx',
      \   },
      \   {
      \    'start': '^\s*{/\*',
      \    'end': '\*/}', 'filetype' : 'jsx',
      \   },
      \ ],
      \ 'typescript': [
      \   {
      \    'synname_pattern': '^jsx',
      \    'filetype' : 'tsx',
      \   },
      \   {
      \    'start': '^\s*{/\*',
      \    'end': '\*/}', 'filetype' : 'tsx',
      \   },
      \ ],
      \}


let g:context_filetype#defaults#_same_filetypes = {
      \ 'cpp': 'c',
      \ 'erb': 'ruby,html,xhtml',
      \ 'html': 'xhtml',
      \ 'xml': 'xhtml',
      \ 'xhtml': 'html,xml',
      \ 'htmldjango': 'html',
      \ 'css': 'scss',
      \ 'scss': 'css',
      \ 'stylus': 'css',
      \ 'less': 'css',
      \ 'tex': 'bib,plaintex',
      \ 'plaintex': 'bib,tex',
      \ 'vimconsole': 'vim',
      \}


let g:context_filetype#defaults#_ignore_patterns = {}


let g:context_filetype#defaults#_comment_patterns = {
      \ 'toml': [
      \   {
      \    'start': '^\s*#',
      \    'end': '$',
      \   },
      \ ],
      \}
