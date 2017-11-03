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

"--------------------------------------------------------------------------------
" options
"--------------------------------------------------------------------------------
set showtabline=2           " always show tab line, even with only one open tab
set noswapfile              " turn off swapfiles - don't want .swp files littering the joint!
set shiftwidth=2            " set tabs to width 2
set tabstop=2               " set tabs to width 2
set noexpandtab             " insert tabs, not spaces, when autoindenting
set autoindent              " use indent from previous line, and that's it (simple)
set ignorecase              " ignore case when searching
set smartcase               " ignore case if search pattern is all lowercase, case-sensitive otherwise
set incsearch               " show search matches as you type
set nohlsearch              " don't highlight incsearch matches
set guioptions-=T           " turn off the never-used toolbar buttons
set clipboard=unnamed       " use the OS X clipboard for copy/paste (if no register is specified).  Thus, yy in vim will write to the system clipboard & can be pasted with Cmd-C
set wildmode=list:longest   " make tab-completion behave like bash shell
set autochdir               " always set vim's pwd to current file dir
set synmaxcol=250           " only syntax highlight the first 250 columns; makes a big speed difference for wide files
set shell=bash\ --login     " source .bash_login etc when executing shellouts; note aliases don't work regardless =(
set cursorline              " enable cursorline coloring
set relativenumber          " show line number column w/ relative line numbers
set visualbell              " screen flash instead of sysbeep on various errors, like ESC-when-already-in-normal-mode
set nowrap
set ruler

set guifont=Monaco:h11
colorscheme mine

if has('gui_running') 
	set scrolloff=10	" maintain 10 lines above/below cursoring downward
else
	set scrolloff=5
endif

"--------------------------------------------------------------------------------
" statusline
"--------------------------------------------------------------------------------
" always show statusline
set laststatus=2

set statusline =
" File description
set statusline +=%f\ %h%m%r%w
" Fully qualified name of the current function (needs tagbar.vim)
set statusline +=\ {%{tagbar#currenttag('%s','','f')}}
" Name of the current branch (needs fugitive.vim)
set statusline +=\ %{fugitive#statusline()}
" <current line> / <total lines> pct
set statusline +=%=col\ %3c,\ line\ %3l/%4L\ %P\ 


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
au BufRead,BufNewFile *.md        set filetype=markdown
au BufRead,BufNewFile *.md        setlocal wrap linebreak nolist display+=lastline


"--------------------------------------------------------------------------------
" java / scalyr coding style (and xml, for pom.xml)
" note adding "<buffer>" to inoremap applies mapping to current buffer only, cool, see :help map-local
"--------------------------------------------------------------------------------

" java.vim syntax coloring tweaks
let java_ignore_javadoc=1          " don't highlight HTML in javadoc
let java_highlight_java_lang_ids=1 " highlight standard java identifiers


au BufRead,BufNewFile *.{java,dashboard,md,xml}  setlocal expandtab|                     " use spaces, not tabs, for indents.  apply to both java & xml (for pom.xml)
au BufRead,BufNewFile *.{java,dashboard,md}      setlocal smartindent|                   " use smart indent options, rather than simple 'autoindent' (this is simple and de-indents closing braces for us, but doesn't go full monty like cindent)
au BufRead,BufNewFile *.{java,dashboard,md}      inoremap <buffer> {} {<CR>}<Esc>kA<CR>| " do not indent closing brace; note if smartident were not used we would need to add ' <tab> ' to the end of this macro

" java make: first, change to the project root ...
au QuickFixCmdPre make Gcd
" ... then run ~/bin/myjavac: (cd ScalyrSite && jt | sed-to-fix-file-paths)
au Filetype java set makeprg=myjavac
set errorformat=%A%f:%l:\ %m,%-Z%p^,%-C%.%#

" 'test-no': comment out all @Test annotations except the current (next above cursor) and return cursor to current location
nmap <leader>tn ma:%s~\V @Test~ /*@Test*/~<CR>`a?@Test<CR>Bxxelxx`a:w<CR>
" 'test-yes': uncomment @Test annotations, return cursor
nmap <leader>ty ma:%s~\V/*@Test*/~@Test~<CR>`a:w<CR>

"--------------------------------------------------------------------------------
" end java / scalyr
"--------------------------------------------------------------------------------


" specify our ISA directories for perl :make
" au FileType Perl set makeprg=perl\ -c\ -I${IHANCE_LIB}\ -Muse_thirdparty_libs\ -I$src/sit/bin/lib\ \ %\ $*
au FileType Perl set makeprg=perl\ \ %\ $*
au FileType Perl set errorformat+=%m\ at\ %f\ line\ %l\.

" bash "fc" command uses $EDITOR to edit last command.  These files are named "bash-fc-..."; set their type accordingly
au BufRead,BufNewFile bash-fc-* set filetype=sh

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


" 'tagbar-toggle'
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

" open new braces; jh style = indent the closing brace
" overridden for .java files in autocmd section above
inoremap {} {<CR><tab>}<Esc>hO


" paste while in insert mode
inoremap <C-P> <ESC>pa

" save file and exit insert mode, if in it
imap <C-S> <ESC>:w<CR>
map <C-S> :w<CR>

" jj = exit insert mode
inoremap jj <ESC>

" use control-space to insert an underscore; slightly easier than typing it...
imap <C-space> _

" perldo!
map <leader>pl :perldo

" open new tab with path of current file expanded
map <leader>e :tabedit <C-R>=expand("%:p:h") . "/" <CR>

" open the current file in Marked 2
map <leader>md :!open -a /Applications/Marked\ 2.app %<CR><CR>

" set reflow wrapping to happen at 120
set textwidth=120
" .. but make sure it doesn't happen automatically
set formatoptions-=t

" reflow a para with ,q:
nnoremap <leader>q gqap
" reflow visually highlighted lines with Q:
vnoremap <leader>q gq

" reload current file from disk (discard unsaved changes)
map <leader>rl :e! %<CR>


"--------------------------------------------------------------------------------
" ,w commands: split screen & misc.
"--------------------------------------------------------------------------------
" ,wo opens vertical split
" ,wk keeps current split, closes others
" ,wc closes current split window
" <C-hd> & <C-l> move cursor back & forth
" ,wh open help in a vertical split
" ,wa writes current buffer to ~/a
nnoremap <leader>wo <C-W>v
nnoremap <C-H> <C-W>h
nnoremap <C-L> <C-W>l
nnoremap <leader>wk <C-W>o
nnoremap <leader>wc <C-W>c
map <leader>wh :vert help 
map <leader>wa :w! ~/a<CR>
map <leader>wb :w! ~/b<CR>

"--------------------------------------------------------------------------------
" ctags
"--------------------------------------------------------------------------------

set tags=~/projects/*/*/.tags,~/projects/*/thirdparty/*/.tags

" regen/update tags file at root for current file's git repo
command! RefreshTags Gcd | normal :!ctags -R -f ./.tags .<CR>

" scalyr-specific version that only scans ScalyrSite/src
command! ScalyrTags Gcd | normal :!ctags -R -f ./.tags ScalyrSite/src<CR>

" open tag-under-cursor in new tab
" http://stackoverflow.com/questions/539231/how-to-use-multiple-tabs-when-tagging-to-a-function-in-vim
nmap <C-Enter> <C-w><C-]><C-w>T
nmap <C-S-Enter> <C-w><C-}>




"--------------------------------------------------------------------------------
" git commands
"--------------------------------------------------------------------------------

" note overriding GIT_PAGER is necessary to skip the 'WARNING: terminal is not fully functional'
" given by less if running in a dumb terminal.  Messing with $LESS might also fix it, but this
" is better because our "git diff" calls araxis and doesn't need a pager regardless
" second <CR> clears the "ENTER to continue" bit

" diff working-vs-repo (this show all changes from last commit, regardless of whether they've been staged or not)
map <leader>gd :!cd %:p:h && GIT_PAGER='' git di HEAD -- %:t<CR><CR>

" 'revert' current file back to HEAD, then reload the file to skip the "file has changed" dialog
map <leader>gr :!cd %:p:h && GIT_PAGER='' git checkout -- %:t<CR><CR>:e! %<CR>

" <leader>gb defined below (uses fugitive)


"--------------------------------------------------------------------------------
" plugins (managed with pathogen) and their bindings
"--------------------------------------------------------------------------------

" pathogen load
call pathogen#runtime_append_all_bundles()
" call pathogen#helptags() " commenting out for speed; use 'plugins.bash -doc' to gen help docs

" put yankring history file into .vim dir, instead of straight in $HOME
let g:yankring_history_dir = '$HOME/.vim'

" equivalent to 'nnoremap Y y$', but with yankring; this *had* been before pathogen but that doesn't make sense to me
function! YRRunAfterMaps()
		nnoremap Y   :<C-U>YRYankCount 'y$'<CR>
endfunction


" Tabular - align code into columns
" mnemonic: 'a'lign
" opens the command for you but doesn't close it - just type your delim and hit enter
map <leader>a :Tabularize /
" flavors: ='>'
map <leader>a> :Tabularize /=><cr>
" flavors: //
map <leader>a/ :Tabularize /\/\/<cr>


" dash.vim - open dash for word under cursor
map <leader>d :Dash<cr>


" quick access to Ag! - write the current file first b/c otherwise Ack throws an error
" also invoke Gcd (fugitive) to set pwd to root of current GIT repo
let g:agprg = 'ag --nogroup --nocolor --column --smart-case'
nnoremap <leader>ag :w<CR> :Gcd<CR> :Ag<space>


"--------------------------------------------------------------------------------
" git commands via plugins
"--------------------------------------------------------------------------------

" 'blame' via fugitive
map <leader>gb :Gblame<CR>

" ctl-j / ctl-k: navigate to prev/next change lines (per gitgutter).  Using same mappings as in Araxis Merge
map <C-J> <Plug>GitGutterNextHunk
map <C-K> <Plug>GitGutterPrevHunk

" make gitgutter snappier at updating the gutter.  Default is 4000.  Tune down if misbehaving
set updatetime=500

"--------------------------------------------------------------------------------
" reference
"--------------------------------------------------------------------------------

" :g/PAT/t$   - copy all lines matching PAT to end of buffer
" highlight lines - see http://www.vim.org/scripts/script.php?script_id=1599
" gd = go to variable definition
" zR = unfold entire file
" ,be = open bufexplorer
