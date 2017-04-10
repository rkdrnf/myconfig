" default Configurations
filetype plugin on
syntax enable

set number

set ts=2
set sw=2
set expandtab

set ic

set noswapfile

let g:netrw_localrmdir='rm -r'

nnoremap <silent> <leader>lc :lclose<CR>
nnoremap <silent> <leader>lo :lopen<CR>


"open last line of the file
autocmd BufReadPost * if @% !~# '\.git[\/\\]COMMIT_EDITMSG$' && line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g`\"" | endif 


" syntastic configs

set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0
let g:syntastic_loc_list_height=5
let g:syntastic_echo_current_error = 0


nnoremap [l :lprev<cr>
nnoremap ]l :lnext<cr>

" Fix syntastic error jumping
function! <SID>LocationPrevious()
  try
    lprev
  catch /^Vim\%((\a\+)\)\=:E553/
    llast
  endtry
endfunction

function! <SID>LocationNext()
  try
    lnext
  catch /^Vim\%((\a\+)\)\=:E553/
    lfirst
  endtry
endfunction

nnoremap <silent> <Plug>LocationPrevious    :<C-u>exe 'call <SID>LocationPrevious()'<CR>
nnoremap <silent> <Plug>LocationNext        :<C-u>exe 'call <SID>LocationNext()'<CR>

" netrw settings

let g:netrw_list_hide= '.*\.meta$'


call plug#begin('~/.vim/plugged')

" Make sure you use single quotes

Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }


Plug 'OmniSharp/omnisharp-vim', { 'do': 'cd server && xbuild' }

Plug 'tpope/vim-dispatch'
Plug 'Robzz/deoplete-omnisharp'


Plug 'scrooloose/syntastic'

Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'

Plug 'tpope/vim-surround'

Plug 'jiangmiao/auto-pairs'

Plug 'SirVer/ultisnips'

Plug 'ervandew/supertab'

" Initialize plugin system
call plug#end()


" fzf configs
command! -bang FLines call fzf#vim#grep(
      \ 'grep -vnITr --color=always --exclude-dir=".svn" --exclude-dir=".git" --exclude=tags --exclude=*\.pyc --exclude=*\.exe --exclude=*\.dll --exclude=*\.zip --exclude=*\.gz "^$"', 
      \ 0,  
      \ {'options': '--reverse --prompt "FLines> "'})

nnoremap <silent> <leader>e :FLines<cr>
nnoremap <silent> <leader>ff :Files<CR>
nnoremap <silent> <leader>fb :Buffers<CR>
nnoremap <silent> <leader>fw :Windows<CR>
nnoremap <silent> <leader>fl :BLines<CR>
nnoremap <silent> <leader>fk :Ag<CR>
nnoremap <silent> K :call SearchWordWithAg()<CR>
vnoremap <silent> K :call SearchVisualSelectionWithAg()<CR>

function! SearchWordWithAg()
  execute 'Ag' expand('<cword>')
endfunction

function! SearchVisualSelectionWithAg() range
  let old_reg = getreg('"')
  let old_regtype = getregtype('"')
  let old_clipboard = &clipboard
  set clipboard&
  normal! ""gvy
  let selection = getreg('"')
  call setreg('"', old_reg, old_regtype)
  let &clipboard = old_clipboard
  execute 'Ag' selection
endfunction

" deoplete configs
let g:deoplete#enable_at_startup=1
let g:deoplete#enable_smart_case=1



call deoplete#custom#set('_', 'converters',
      \ ['converter_remove_paren'])


inoremap <expr> <Tab> pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
"inoremap <expr> . pumvisible() ? "\<C-n>." : "."
"inoremap <silent> <expr> <Space> (pumvisible() ? "\<C-n>" : "") . "\<C-]>\<C-R>=AutoPairsSpace()\<CR>"



"autopairs configs
let g:AutoPairsMapSpace=0 


" supertab configs
let g:SuperTabDefaultCompletionType = 'context'
let g:SuperTabContextDefaultCompletionType = "<c-x><c-o>"
let g:SuperTabDefaultCompletionTypeDiscovery = ["&omnifunc:<c-x><c-o>","&completefunc:<c-x><c-n>"]
let g:SuperTabClosePreviewOnPopupClose = 1

" OmniSharp configs
let g:Omnisharp_server_config_name = '~/.vim/plugged/omnisharp-vim/server/config.json'
set completeopt=longest,menuone,preview
let g:syntastic_cs_checkers = ['syntax', 'semantic', 'issues']

augroup omnisharp_commands
  autocmd!

  "Set autocomplete function to OmniSharp (if not using YouCompleteMe completion plugin)
  autocmd FileType cs setlocal omnifunc=OmniSharp#Complete

  " Builds can also run asynchronously with vim-dispatch installed
  autocmd FileType cs nnoremap <leader>b :wa!<cr>:OmniSharpBuildAsync<cr>


  " automatic syntax check on events (TextChanged requires Vim 7.4)
  autocmd BufEnter,TextChanged,InsertLeave *.cs SyntasticCheck

  " Automatically add new cs files to the nearest project on save
  autocmd BufWritePost *.cs call OmniSharp#AddToProject()

  "show type information automatically when the cursor stops moving
  autocmd CursorHold *.cs call OmniSharp#TypeLookupWithoutDocumentation()

  "The following commands are contextual, based on the current cursor position.

  autocmd FileType cs nnoremap gd :OmniSharpGotoDefinition<cr>
  autocmd FileType cs nnoremap <leader>fi :OmniSharpFindImplementations<cr>
  autocmd FileType cs nnoremap <leader>ft :OmniSharpFindType<cr>
  autocmd FileType cs nnoremap <leader>fs :OmniSharpFindSymbol<cr>
  autocmd FileType cs nnoremap <leader>fu :OmniSharpFindUsages<cr>
  "finds members in the current buffer
  autocmd FileType cs nnoremap <leader>fm :OmniSharpFindMembers<cr>
  " cursor can be anywhere on the line containing an issue
  autocmd FileType cs nnoremap <leader>x  :OmniSharpFixIssue<cr>
  autocmd FileType cs nnoremap <leader>fx :OmniSharpFixUsings<cr>
  autocmd FileType cs nnoremap <leader>tt :OmniSharpTypeLookup<cr>
  autocmd FileType cs nnoremap <leader>dc :OmniSharpDocumentation<cr>
  "navigate up by method/property/field
  autocmd FileType cs nnoremap <C-K> :OmniSharpNavigateUp<cr>
  "navigate down by method/property/field
  autocmd FileType cs nnoremap <C-J> :OmniSharpNavigateDown<cr>

augroup END

" this setting controls how long to wait (in ms) before fetching type / symbol information.
set updatetime=500
" Remove 'Press Enter to continue' message when type information is longer than one line.
set cmdheight=2

" Contextual code actions (requires CtrlP or unite.vim)
nnoremap <leader><space> :OmniSharpGetCodeActions<cr>
" Run code actions with text selected in visual mode to extract method
vnoremap <leader><space> :call OmniSharp#GetCodeActions('visual')<cr>

" rename with dialog
nnoremap <leader>nm :OmniSharpRename<cr>
nnoremap <F2> :OmniSharpRename<cr>
" rename without dialog - with cursor on the symbol to rename... ':Rename newname'
command! -nargs=1 Rename :call OmniSharp#RenameTo("<args>")

" Force OmniSharp to reload the solution. Useful when switching branches etc.
nnoremap <leader>rl :OmniSharpReloadSolution<cr>
nnoremap <leader>cf :OmniSharpCodeFormat<cr>
" Load the current .cs file to the nearest project
nnoremap <leader>tp :OmniSharpAddToProject<cr>

" (Experimental - uses vim-dispatch or vimproc plugin) - Start the omnisharp server for the current solution
nnoremap <leader>ss :OmniSharpStartServer<cr>
nnoremap <leader>sp :OmniSharpStopServer<cr>

" Add syntax highlighting for types and interfaces
nnoremap <leader>th :OmniSharpHighlightTypes<cr>
"Don't ask to save when changing buffers (i.e. when jumping to a type definition)
set hidden

" Enable snippet completion, requires completeopt-=preview
" let g:OmniSharp_want_snippet=1
let g:OmniSharp_selector_ui = 'fzf'    " Use fzf.vim

