#!/usr/bin/env bash
 
# this is the world's ~simplest~ dumbest plugin manager
install() (
  set -e
  local VENDOR=${1}
  local PLUGIN=${2}
  local GITTAG=${3}

  local PLUGDIR="pack/$VENDOR/start"
  [ -d "$PLUGDIR/$PLUGIN" ] && echo "Plugin already installed: $VENDOR/$PLUGIN at $PLUGDIR/$PLUGIN" && return 1 

  mkdir -p $PLUGDIR && cd $PLUGDIR

  # note we used submodules for a minute, but they are terribly annoying and don't seem to work
  # so we just have 'pack' in .gitignore, and simply clone into it
  git clone https://github.com/$VENDOR/$PLUGIN
  cd $PLUGIN
  git checkout $GITTAG
)

install tpope vim-fugitive v2.0
install tpope vim-surround v2.0
install godlygeek tabular 1.0.0
install preservim tagbar v2.6.1
install airblade vim-gitgutter HEAD
install rizzatti dash.vim HEAD
install jlanzarotta bufexplorer 7.4.4
install vim-scripts YankRing.vim 17.0
install mkitt tabline.vim HEAD

# these were installed w/ vim, but i think are unused. not installing yet
# ag/
# vim-easymotion/
# vim-peepopen/
