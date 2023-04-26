" This must be first, because it changes other options as side effect
" note this is set by default by macvim, i think, but doesn't hurt to state
set nocompatible

"--------------------------------------------------------------------------------
" map leader and quick .vimrc access
"--------------------------------------------------------------------------------
" see http://nvie.com/posts/how-i-boosted-my-vim/
" change the mapleader from \ to ,
let mapleader=","

" Quickly edit/reload the vimrc file
nmap <silent> <leader>ve :tabedit $MYVIMRC<CR>
nmap <silent> <leader>vl :so $MYVIMRC<CR>

" use ";" for ":" - no need to hit shift when entering commands
nnoremap ; :
vnoremap ; :

" paste from the 0 register (not the unnamed), to allow for repeatedly pasting the same text over other text
" particularly important when replacing N lines with some new variant
" note that `y` populates the 0 register by default, so we only need to remap p
vnoremap p "0p

"--------------------------------------------------------------------------------
" options
"--------------------------------------------------------------------------------
set showtabline=2            " always show tab line, even with only one open tab
set noswapfile               " turn off swapfiles - don't want .swp files littering the joint!
set shiftwidth=2             " set tabs to width 2
set tabstop=2                " set tabs to width 2
set expandtab                " insert spaces, not tabs, when autoindenting
set autoindent               " use indent from previous line, and that's it (simple)
set ignorecase               " ignore case when searching
set smartcase                " ignore case if search pattern is all lowercase, case-sensitive otherwise
set incsearch                " show search matches as you type
set nohlsearch               " don't highlight incsearch matches
set guioptions-=T            " turn off the never-used toolbar buttons
set clipboard=unnamed        " use the OS X clipboard for copy/paste (if no register is specified).  Thus, yy in vim will write to the system clipboard & can be pasted with Cmd-C
set wildmode=list:longest    " make tab-completion behave like bash shell
set autochdir                " always set vim's pwd to current file dir
set synmaxcol=250            " only syntax highlight the first 250 columns; makes a big speed difference for wide files
set shell=bash\ --login      " source .bash_login etc when executing shellouts; note aliases don't work regardless =(
set cursorline               " enable cursorline coloring
set relativenumber           " show line number column w/ relative line numbers
set visualbell               " screen flash instead of sysbeep on various errors, like ESC-when-already-in-normal-mode
set laststatus=2             " always show statusline
set statusline =%f\ %h%m%r%w " File description, note this is = not +=
set nowrap
set ruler

set guifont=Monaco:h10
colorscheme mine
syntax on

if has('gui_running') " detect a gui environment (macvim, vimr, etc)
  set scrolloff=10     " maintain 10 lines above/below cursoring downward
else
  set scrolloff=5
  set norelativenumber " turn off line number column
  set number           " display absolute line numbers; useful for cut-and-paste
  set t_Co=256         " enable broader color palette
endif

" out of the box, macvim supports standard OS X prev/next tab keys, but vimr does not, so we need these to replicate
if has('gui_vimr')
  map <S-D-}> :tabnext<CR>
  map <S-D-{> :tabnext -<CR>
endif

"--------------------------------------------------------------------------------
" filetypes, autocommands
"--------------------------------------------------------------------------------
au BufRead,BufNewFile *.readme    set filetype=sh
au BufRead,BufNewFile *.txt       set filetype=sh
au BufRead,BufNewFile *.conf      set filetype=sh
au BufRead,BufNewFile *.log       set filetype=java
au BufRead,BufNewFile *.object    set filetype=xml
au BufRead,BufNewFile *.page      set filetype=html
au BufRead,BufNewFile *.cls       set filetype=apex
au BufRead,BufNewFile *.apex      set filetype=apex
au BufRead,BufNewFile *.trigger   set filetype=apex
au BufRead,BufNewFile *.apex.in   set filetype=apex
au BufRead,BufNewFile *.component set filetype=html
au BufRead,BufNewFile *.ashx      set filetype=cs
au BufRead,BufNewFile *.aspx      set filetype=cs
au BufRead,BufNewFile *.config    set filetype=xml
au BufRead,BufNewFile *.config.in set filetype=xml
au BufRead,BufNewFile *.resource  set filetype=javascript
au BufRead,BufNewFile *.dashboard set filetype=javascript
au BufRead,BufNewFile *.gs        set filetype=javascript
au BufRead,BufNewFile *.md        set filetype=markdown
au BufRead,BufNewFile status      set filetype=markdown
au BufRead,BufNewFile czar-status set filetype=markdown
au BufRead,BufNewFile *.md        setlocal wrap linebreak nolist display+=lastline formatoptions-=c
au BufRead,BufNewFile bash-fc-*   set filetype=sh    " bash 'fc' command uses $EDITOR to edit last command.  These files are named "bash-fc-..."; set their type accordingly




"--------------------------------------------------------------------------------
" scalyr/java coding style
" FYI (not in use) adding "<buffer>" to inoremap applies mapping to current buffer only, cool, see :help map-local
"--------------------------------------------------------------------------------

au BufRead,BufNewFile */src/scalyr/my.scalyr.wiki/remote-files/* set filetype=javascript            " dashboards & datatables

" mark FC2 files obviously, for A/B coding
au BufEnter,BufRead,BufNewFile */src/scalyr/FC2/* colorscheme desert
au BufLeave                    */src/scalyr/FC2/* colorscheme mine 


" java.vim syntax coloring tweaks
let java_ignore_javadoc=1          " don't highlight HTML in javadoc
let java_highlight_java_lang_ids=1 " highlight standard java identifiers

set smartindent               " use smart indent options, rather than simple 'autoindent' (this is simple and de-indents closing braces for us, but doesn't go full monty like cindent)

" do not indent closing brace; note if smartident were not used we would need to add ' <tab> ' to the end of this macro
inoremap {} {<CR>}<Esc>kA<CR>

au BufWritePre        */src/scalyr/*,*/GoogleDrive/NOTES/*  call s:strip_ws()|                      " remove trailing whitespace on save; strip_ws defined below

" 'test-no': comment out all @Test annotations except the current (next above cursor) and return cursor to current location
nmap <leader>tn ma:%s~\v (\@\w*Test)~ /*\1 JH-NOCOMMIT*/~<CR>`a?@.*Test<CR>Bxxeldf/`a:w<CR>
" 'test-yes': uncomment @Test annotations, return cursor
nmap <leader>ty ma:%s~\v/\*(.*) JH-NOCOMMIT\*/~\1~<CR>`a:w<CR>

"--------------------------------------------------------------------------------
" end java / scalyr
"--------------------------------------------------------------------------------

" strip trailing ws & return cursor to current position; h/t jeberle
fun! s:strip_ws()
  let l = line('.')
  let c = col('.')
  keepp %s/\s\+$//e
  call cursor(l, c)
endf

"--------------------------------------------------------------------------------
" key mappings for standard (non-plugin) functionality
"--------------------------------------------------------------------------------


" fold the current code section (as delimited by "#---" or "//---"
" it works by moving upward to the previous --- line (or start-of-file),
" setting a mark (Z), then moving down to the next --- line (or end-of-file),
" and then folding up to the mark
" and then finding the _next_ section mark & moving down three lines so we can repeat this command again and again
" note the | operator needs to be double-escaped here; not sure why

" move to next "fold section" per above, or EOF
nmap <leader>f /\(\%$\\|^\s*[#"/*<%]*\s*-----\)<CR>
" and to previous "fold section" per above
nmap <leader>F ?\(\%^\\|^\s*[#"/*<%]*\s*-----\)<CR>
" fold current section using above shortcuts
nmap <leader>z ,FmZ,fkzf`Z,fjjj

" sort-numeric: use built-in `sort n`, which handles alphanumeric but only in reverse, then reverse the buffer
nmap <leader>sn :%sort n<CR>:g/^/m0<CR>
vmap <leader>sn :'<,'>sort n<CR>gv<CR>:'<,'>!tail -r<CR>

" 'tagbar-toggle'
let g:tagbar_width = 80
nmap <leader>tb :TagbarToggle<CR>

" horizontal rule
imap <D-H> --------------------------------------------------------------------------------<CR>
nmap <D-H> 0i<D-H><Esc>

" insert newlines without entering insert mode (like o/O, but without going into insert mode)
map <S-Enter> O<Esc>
map <CR> o<Esc>


" alt-shift-{J,K} - scroll file & keep cursor centered
map <D-J> jzz
map <D-K> kzz
imap <D-J> <Esc>jzz
imap <D-K> <Esc>kzz

" paste while in insert mode
inoremap <C-P> <ESC>pa

" save file and exit insert mode, if in it
imap <C-S> <ESC>:w<CR>
map <C-S> :w<CR>

" jj = exit insert mode
inoremap jj <ESC>

" perldo!
map <leader>pl :perldo

" open new tab with path of current file expanded
map <leader>e :tabedit <C-R>=expand("%:p:h") . "/" <CR>

" open the current file in Marked 2
map <leader>md :!open -a /Applications/Marked\ 2.app "%"<CR><CR>

" set reflow wrapping to happen at 120
" set textwidth=120
" .. but make sure it doesn't happen automatically
" set formatoptions-=t

" reflow a para with ,q:
nnoremap <leader>q gqap
" reflow visually highlighted lines with Q:
vnoremap <leader>q gq

" reload current file from disk (discard unsaved changes)
map <leader>rl :e! %<CR>


"--------------------------------------------------------------------------------
" ,w commands: split screen & misc.
"--------------------------------------------------------------------------------
" ,wo opens vertical split, and shrink left pane by 60 to center new pane
" ,wk keeps current split, closes others
" ,wc closes current split window
" <C-hd> & <C-l> move cursor back & forth
" ,wh open help in a vertical split
" ,wa writes current buffer to ~/a
nnoremap <leader>wo <C-W>v10<C-W><
nnoremap <C-H> <C-W>h
nnoremap <C-L> <C-W>l
nnoremap <leader>wk <C-W>o
nnoremap <leader>wc <C-W>c
map <leader>wh :vert help 
map <leader>wa :w! ~/a<CR>
map <leader>wb :w! ~/b<CR>


"--------------------------------------------------------------------------------
" git commands that don't require a plugin
"--------------------------------------------------------------------------------

" note overriding GIT_PAGER is necessary to skip the 'WARNING: terminal is not fully functional'
" given by less if running in a dumb terminal.  Messing with $LESS might also fix it, but this
" is better because our "git diff" calls araxis and doesn't need a pager regardless
" second <CR> clears the "ENTER to continue" bit

" diff working-vs-repo (this show all changes from last commit, regardless of whether they've been staged or not)
map <leader>gd :!cd %:p:h && GIT_PAGER='' git di HEAD -- %:t<CR><CR>

" 'revert' current file back to HEAD, then reload the file to skip the "file has changed" dialog
map <leader>gr :!cd %:p:h && GIT_PAGER='' git checkout -- %:t<CR><CR>:e! %<CR>

" other fugitive-based git commands defined below (eg, <leader>gb)



"--------------------------------------------------------------------------------
" PLUGINS
"--------------------------------------------------------------------------------

"--------------------------------------------------------------------------------
" plugin: yankring
"--------------------------------------------------------------------------------
" put yankring history file into .vim dir, instead of straight in $HOME
let g:yankring_history_dir = '$HOME/.vim'

" equivalent to 'nnoremap Y y$', but with yankring
function! YRRunAfterMaps()
    nnoremap Y   :<C-U>YRYankCount 'y$'<CR>
endfunction



"--------------------------------------------------------------------------------
" plugin: matsushita/tagbar
"--------------------------------------------------------------------------------

" tagbar options & statusline tweaks therefrom
set statusline +=\ {%{tagbar#currenttag('%s','','f')}}
let g:tagbar_iconchars = ['▸', '▾']

"--------------------------------------------------------------------------------
" plugin: fugitive
"--------------------------------------------------------------------------------

" macvim-vs-terminal vim differences; we use terminal vim for cutting-and-pasting into emails
" so we customize with that goal in mind
if has('gui_running')
  " current branch
  set statusline +=\ :%{fugitive#head()}
  set statusline +=%=col\ %3c,\ line\ %3l/%4L\ %P\ 
endif

" 'blame' via fugitive
map <leader>gb :Gblame<CR>


" modified from https://github.com/baroldgene/vim-github-links
function! GithubLink()
  " set pwd to repo root dir...
  Gcd
  " ... so bufname gives us a path from the top
  let filename = bufname("%")
  let linenumber = line(".")
  let url = 'https://github.com/scalyr/scalyr/blob/master/' . filename . "#L" . linenumber
  let output = system('pbcopy', url)
  return url
endfunction

command! GithubLink call s:GithubLink()

nnoremap <leader>gl :echo GithubLink()<cr>


"--------------------------------------------------------------------------------
" ctags - not a plugin, but depends on fugitive
"--------------------------------------------------------------------------------

set tags=~/src/*/*/.tags,~/src/*/.tags,~/src/*/thirdparty/*/.tags

command! RefreshTags Gcd | normal :!ctags -R -f ./.tags .<CR>                    " regen/update tags file at root for current file's git repo
command! ScalyrTags Gcd | normal :!ctags -R -f ./.tags ScalyrSite/{src,test}<CR> " scalyr-specific version that only scans ScalyrSite/src

" open tag-under-cursor in new tab, h/ http://stackoverflow.com/questions/539231/how-to-use-multiple-tabs-when-tagging-to-a-function-in-vim
nmap <C-Enter> <C-w><C-]><C-w>T


"--------------------------------------------------------------------------------
" plugin: tabular
"--------------------------------------------------------------------------------

" Tabular - align code into columns
" mnemonic: 'a'lign
" opens the command for you but doesn't close it - just type your delim and hit enter
map <leader>a :Tabularize /
" flavors: ='>'
map <leader>a> :Tabularize /=><cr>
" flavors: //
map <leader>a/ :Tabularize /\/\/<cr>


"--------------------------------------------------------------------------------
" gitgutter
"--------------------------------------------------------------------------------
" undo (revent) current hunk, via gitgutter
map <leader>gu :GitGutterUndoHunk<CR>

" ctl-j / ctl-k: navigate to prev/next change lines (per gitgutter).  Using same mappings as in Araxis Merge
map <C-J> <Plug>(GitGutterNextHunk)
map <C-K> <Plug>(GitGutterPrevHunk)

" make gitgutter snappier at updating the gutter.  Default is 4000.  Tune down if misbehaving
set updatetime=500


"--------------------------------------------------------------------------------
" plugin: dash
"--------------------------------------------------------------------------------

" dash.vim - open dash for word under cursor
map <leader>d :Dash<cr>



"--------------------------------------------------------------------------------
" reference
"--------------------------------------------------------------------------------

" :g/PAT/t$   - copy all lines matching PAT to end of buffer
" highlight lines - see http://www.vim.org/scripts/script.php?script_id=1599
" gd = go to variable definition
" zR = unfold entire file
" ,be = open bufexplorer
