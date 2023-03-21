let g:UltiSnipsExpandTrigger = '<f5>'

" project specific, but oh well. better than exrc!
au FileType c nnoremap <silent> ;m :Focus make build -j 10<CR>:Dispatch<CR>
au FileType c nnoremap <silent> ;r :Focus make run -j 10<CR>:Dispatch<CR>
au FileType c nnoremap <silent> ;cm :Focus make clean; make build -j 10<CR>:Dispatch<CR>
au FileType c nnoremap <silent> ;cr :Focus make clean; make run -j 10<CR>:Dispatch<CR>
au FileType c nnoremap <silent> ;d :VimuxRunCommand "lldb ./bin/game"<CR>
au FileType c nnoremap <silent> ;dm :VimuxRunCommand "make build -j 10 && lldb ./bin/game"<CR>
au FileType c nnoremap <silent> ;dc :VimuxRunCommand "make clean -j 10 && make build -j 10 && lldb ./bin/game"<CR>
au FileType c nnoremap <silent> ;tm :VimuxRunCommand "make build -j 10"<CR>
au FileType c nnoremap <silent> ;tr :VimuxRunCommand "make run -j 10"<CR>
au FileType c nnoremap <silent> ;tc :VimuxRunCommand "make clean && make run -j 10"<CR>

au FileType zig nnoremap <silent> ;m :make<CR>
au FileType zig nnoremap <silent> ;r :make run<CR>

" C++ helpers

" switch between hpp and cpp
au BufEnter,BufNew *.cpp nnoremap <silent> ;p :e %<.hpp<CR>
au BufEnter,BufNew *.hpp nnoremap <silent> ;p :e %<.cpp<CR>

au BufEnter,BufNew *.cpp nnoremap <silent> ;vp :leftabove vs %<.hpp<CR>
au BufEnter,BufNew *.hpp nnoremap <silent> ;vp :rightbelow vs %<.cpp<CR>

au BufEnter,BufNew *.cpp nnoremap <silent> ;xp :leftabove split %<.hpp<CR>
au BufEnter,BufNew *.hpp nnoremap <silent> ;xp :rightbelow split %<.cpp<CR>

" switch between h and c
au BufEnter,BufNew *.c nnoremap <silent> ;p :e %<.h<CR>
au BufEnter,BufNew *.h nnoremap <silent> ;p :e %<.c<CR>

au BufEnter,BufNew *.c nnoremap <silent> ;vp :leftabove vs %<.h<CR>
au BufEnter,BufNew *.h nnoremap <silent> ;vp :rightbelow vs %<.c<CR>

au BufEnter,BufNew *.c nnoremap <silent> ;xp :leftabove split %<.h<CR>
au BufEnter,BufNew *.h nnoremap <silent> ;xp :rightbelow split %<.c<CR>

" open same file in vertical/horizonal splits
nnoremap <silent> ;vmp :leftabove vsplit %<CR>
nnoremap <silent> ;xmp :leftabove split %<CR>

" surround with std::optional
nnoremap <silent> ;cso :execute 's/\(' . expand('<cWORD>') . '\)/std::optional<\1>'<CR>:noh<CR>

" function which copies .hpp/.cpp and auto-rename in buffers
function! CPPCopy(path, newName, oldTypeName, newTypeName)
    let l:basePath  = fnamemodify(a:path, ':h')
    let l:baseName = split(fnamemodify(a:path, ':t'), '\.')[0]
    let l:oldCppPath = join([l:basePath, "/", l:baseName, ".cpp"], "")
    let l:oldHppPath = join([l:basePath, "/", l:baseName, ".hpp"], "")
    let l:newCppPath = join([l:basePath, "/", a:newName, ".cpp"], "")
    let l:newHppPath = join([l:basePath, "/", a:newName, ".hpp"], "")

    let l:oldCppExists = filereadable(l:oldCppPath)

	if !filereadable(l:oldHppPath)
		echo "aborted: file " . l:oldHppPath " does not exist"
		return
	endif

	if filereadable(l:newHppPath)
		let l:text = "File " . l:newHppPath . " already exists, continue?"
		if confirm(l:text, "&y\n&n", 1) != 1
			echo "aborted"
			return
		endif
	endif

	if l:oldCppExists && filereadable(l:newCppPath)
		let l:text = "File " . l:newCppPath . " already exists, continue?"
		if confirm(l:text, "&y\n&n", 1) != 1
			echo "aborted"
			return
		endif
	endif

	let l:sed0 = join(["s/", tolower(a:oldTypeName), "/", tolower(a:newTypeName), "/g"], "")
	let l:oldTypeNameCamel = substitute(a:oldTypeName, "<./", "\u&", "")
	let l:newTypeNameCamel = substitute(a:newTypeName, "<./", "\u&", "")
	let l:sed1 = join(["s/", l:oldTypeNameCamel, "/", l:newTypeNameCamel, "/g"], "")

	call system(join(["cp ", l:oldHppPath, " ", l:newHppPath], ""))
	call system(join(["sed -i '' '", l:sed0, "' ", l:newHppPath], ""))
	call system(join(["sed -i '' '", l:sed1, "' ", l:newHppPath], ""))

    if l:oldCppExists
	    call system(join(["cp ", l:oldCppPath, " ", l:newCppPath], ""))
	    call system(join(["sed -i '' '", l:sed0, "' ", l:newCppPath], ""))
	    call system(join(["sed -i '' '", l:sed1, "' ", l:newCppPath], ""))
    endif

	let choice = confirm("open " . l:newHppPath . " in:", "&here\n&vsplit\n&hsplit\n&none", 4)
	if choice == 1
		exec "e " . l:newHppPath
	elseif choice == 2
		exec "vsplit " . l:newHppPath
	elseif choice == 3
		exec "split " . l:newHppPath
	endif
endfunction

function! CPPCopyComplete(argLead, cmdLine, cursorPos)
	if count((a:cmdLine)[0:(a:cursorPos)], " ") > 1
		return []
	else
		return getcompletion(a:argLead, 'file')
	endif
endfunction

command! -nargs=* -complete=customlist,CPPCopyComplete CPPCopy call CPPCopy(<f-args>)

function! CPPImpl() range
	" convert lines into marks so things aren't messed up when deleted
	execute ':' . a:firstline
	normal 0
	normal mm
	execute ':' . a:lastline
	normal $
	normal mn

	let myRange = "'m,'n"

	" ask user for class name
	let className = input("class name: ")

	" remove indentation
	'm,'nleft

	" remove override
	execute 'lockmarks ' . myRange . 's/\(\.*\)\s+(override)\s*\(.*\)/\1 \2/ge'

	" remove explicit, virtual
	execute 'lockmarks ' . myRange . 's/(virtual)\s*\(.*\);/\1 \2;/ge'

	" replace all lines with definitions
	" \1: return type
	" \2: return type extras (*/&/etc.)
	" \3: function name
	" \4: rest of signature excluding ";"
	"                     \1        \2                \3     \4
	execute myRange . 's/\(.*\)\s\+\([^a-zA-Z0-9_]*\)\(.*\)(\(.*\);$/\1 \' . className . '::\3(\4 {\r\r}/g'

	" remove lines with comments
    execute 'lockmarks ' . myRange . 'g/\/\//d'
endfunction

command! -range PassRange CPPImpl call CPPImpl(<f-args>)

" cpi -> CPPImpl
vnoremap <silent> <Leader>cpi :<C-U>CPPImpl<CR>

" zig config
au FileType zig nmap <Leader>dt <cmd>lua vim.lsp.buf.definition()<CR>
au FileType zig nmap <Leader>h  <cmd>lua vim.lsp.buf.hover()<CR>
au FileType zig nmap <Leader>p  <cmd>lua vim.lsp.buf.signature_help()<CR>
au FileType zig nmap <Leader>gd  <cmd>lua vim.lsp.buf.document_symbol()<CR>
au FileType zig setlocal omnifunc=v:lua.vim.lsp.omnifunc

" enable history for fzf
let g:fzf_history_dir = '~/.local/share/fzf-history'

" easy-motion
" disable default mappings, turn on case-insensitivity
let g:EasyMotion_do_mapping = 0
let g:EasyMotion_smartcase = 1

" find character
nmap .s <Plug>(easymotion-overwin-f)

" find 2 characters
nmap .d <Plug>(easymotion-overwin-f2)

" global word find
nmap .g <Plug>(easymotion-overwin-w)

" t/f (find character on line)
nmap .t <Plug>(easymotion-tl)
nmap .f <Plug>(easymotion-fl)

" move to start of line when jumping lines
let g:EasyMotion_startofline = 1

" jk/l motions: Line motions
nmap .j <Plug>(easymotion-j)
nmap .k <Plug>(easymotion-k)
nmap ./ <Plug>(easymotion-overwin-line)

nmap .a <Plug>(easymotion-jumptoanywhere)

" faster updates!
set updatetime=100

" no hidden buffers
set nohidden

" history
set undodir=~/.cache/nvim/undodir
set undofile

" automatically read on change
set autoread

" auto-pairs
let g:AutoPairsFlyMode = 0
let g:AutoPairsShortcutBackInsert = '<M-b>'

" ;t is trim
nnoremap ;t <silent> :Trim<CR>

" easy search
nnoremap ;s :s/

" easy search/replace with current visual selection
xnoremap ;s y:%s/<C-r>"//g<Left><Left>

" easy search/replace on current line with visual selection
xnoremap ;ls y:.s/<C-r>"//g<Left><Left>

" ;w is save
noremap <silent> ;w :update<CR>

";f formats in normal mode
noremap <silent> ;f gg=G``:w<CR>

" language-specific formatters
au FileType cpp set formatprg=clang-format | set equalprg=clang-format

let g:lion_squeeze_spaces = 1

" no folds, ever
set foldlevelstart=99

" rainbow parens
let g:rainbow_active = 1

" rust config
let g:rustfmt_autosave = 1

set nocompatible
let c_no_curly_error=1

" Python
let g:python3_host_prog="/usr/local/bin/python3"

" Get syntax files from config folder
set runtimepath+=~/.config/nvim/syntax

" fzf in runtimepath
set rtp+=/usr/local/opt/fzf

" Use ripgrep as grep
set grepprg=rg\ --vimgrep\ --smart-case\ --follow

" Colorscheme
set termguicolors
let g:gruvbox_contrast_dark='hard'
let g:gruvbox_contrast_light='hard'
colorscheme gruvbox
hi LspCxxHlGroupMemberVariable guifg=#83a598

" alt-a as esc-a for select
nmap <esc>a <a-a>

" Disable C-z from job-controlling neovim
nnoremap <c-z> <nop>

" Ctrl-k closes all floating windows in normal mode
nmap <c-k> call coc#float#close_all()

" Remap C-c to <esc>
nmap <c-c> <esc>
imap <c-c> <esc>
vmap <c-c> <esc>
omap <c-c> <esc>

" Map insert mode CTRL-{hjkl} to arrows
imap <C-h> <Left>
imap <C-j> <Down>
imap <C-k> <Up>
imap <C-l> <Right>

" same in normal mode
nmap <C-h> <Left>
nmap <C-j> <Down>
nmap <C-k> <Up>
nmap <C-l> <Right>

" Syntax highlighting
syntax on

" Position in code
set number
set ruler

" Don't make noise
set visualbell

" default file encoding
set encoding=utf-8

" Line wrap
set wrap

" C-p: FZF find files
nnoremap <silent> <C-p> :Files<CR>

" C-g: FZF ('g'rep)/find in files
nnoremap <silent> <C-g> :Rg<CR>

" <leader>p: find and replace with nvim-spectre
nnoremap <silent> <leader>l :lua require('spectre').open()<CR>

" <leader>fr: find and replace in current file
nnoremap <silent> <leader>g viw:lua require('spectre').open_file_search()<CR>

" <leader>s: symbols outline
nnoremap <silent> <leader>s :SymbolsOutline<CR>

" Function to set tab width to n spaces
function! SetTab(n)
  let &tabstop=a:n
  let &shiftwidth=a:n
  let &softtabstop=a:n
  set expandtab
  set autoindent
  set smartindent
endfunction

command! -nargs=1 SetTab call SetTab(<f-args>)

set noexpandtab
set autoindent
set smartindent

" Function to trim extra whitespace in whole file
function! Trim()
  let l:save = winsaveview()
  keeppatterns %s/\s\+$//e
  call winrestview(l:save)
endfun

command! -nargs=0 Trim call Trim()

set laststatus=2

" Highlight search results
set hlsearch
set incsearch

set t_Co=256

" Binary files -> xxd
augroup Binary
  au!
  au BufReadPre  *.bin let &bin=1
  au BufReadPost *.bin if &bin | %!xxd
  au BufReadPost *.bin set ft=xxd | endif
  au BufWritePre *.bin if &bin | %!xxd -r
  au BufWritePre *.bin endif
  au BufWritePost *.bin if &bin | %!xxd
  au BufWritePost *.bin set nomod | endif
augroup END

" colorcolumn 80 when opening C/C++
autocmd BufRead,BufNewFile *.c setlocal colorcolumn=80
autocmd BufRead,BufNewFile *.h setlocal colorcolumn=80
autocmd BufRead,BufNewFile *.cpp setlocal colorcolumn=80
autocmd BufRead,BufNewFile *.hpp setlocal colorcolumn=80
autocmd BufRead,BufNewFile *.c SetTab 4
autocmd BufRead,BufNewFile *.h SetTab 4
autocmd BufRead,BufNewFile *.cpp SetTab 4
autocmd BufRead,BufNewFile *.hpp SetTab 4

" C/C++ indent options: fix extra indentation on function continuation
set cino=(0,W4

" colorcolumn 80, tab width 4 for shaders
autocmd BufRead,BufNewFile *.sc setlocal colorcolumn=80 | SetTab 4

" nim config
autocmd BufRead,BufNewFile *.nim  setlocal colorcolumn=80
autocmd BufRead,BufNewFile *.nims setlocal colorcolumn=80
autocmd BufRead,BufNewFile *.nim SetTab 4
autocmd BufRead,BufNewFile *.nims SetTab 4

" ASM == JDH8
augroup jdh8_ft
  au!
  autocmd BufNewFile,BufRead *.asm    set filetype=jdh8
augroup END

" SQL++ == SQL
augroup sqlpp_ft
  au!
  autocmd BufNewFile,BufRead *.sqlp   set syntax=sql
augroup END

" .S == gas
augroup gas_ft
  au!
  autocmd BufNewFile,BufRead *.S      set syntax=gas
augroup END

" .vs = glsl
augroup vs_ft
  au!
  autocmd BufNewFile,BufRead *.vs     set syntax=glsl
augroup END

" .fs = glsl
augroup fs_ft
  au!
  autocmd BufNewFile,BufRead *.fs     set syntax=glsl
augroup END

" .sc = glsl
augroup sc_ft
  au!
  autocmd BufNewFile,BufRead *.sc     set filetype=glsl
augroup END

" JFlex syntax highlighting
augroup jfft
  au BufRead,BufNewFile *.flex,*.jflex    set filetype=jflex
augroup END
au Syntax jflex    so ~/.vim/syntax/jflex.vim

" Mouse support
set mouse=a

" Map F8 to Tagbar
nmap <F8> :TagbarToggle<CR>

" disable backup files
set nobackup
set nowritebackup

set shortmess+=c

set signcolumn=yes

au FileType text set colorcolumn=80

" show syntax group of symbol under cursor
function! SynStack()
  if !exists("*synstack")
    return
  endif
  echo map(synstack(line('.'), col('.')), 'synIDattr(v:val, "name")')
endfunc

" nvim-dap bindings
nnoremap <silent> <F5> <Cmd>lua require'dap'.continue()<CR>
nnoremap <silent> <F10> <Cmd>lua require'dap'.step_over()<CR>
nnoremap <silent> <F11> <Cmd>lua require'dap'.step_into()<CR>
nnoremap <silent> <F12> <Cmd>lua require'dap'.step_out()<CR>
nnoremap <silent> <Leader>b <Cmd>lua require'dap'.toggle_breakpoint()<CR>
nnoremap <silent> <Leader>B <Cmd>lua require'dap'.set_breakpoint(vim.fn.input('Breakpoint condition: '))<CR>
nnoremap <silent> <Leader>lp <Cmd>lua require'dap'.set_breakpoint(nil, nil, vim.fn.input('Log point message: '))<CR>
nnoremap <silent> <Leader>dr <Cmd>lua require'dap'.repl.open()<CR>
nnoremap <silent> <Leader>dl <Cmd>lua require'dap'.run_last()<CR>
