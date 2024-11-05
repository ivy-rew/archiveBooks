#!/bin/bash

# post processing for Archive.org books:
# https://gist.github.com/cemerson/043d3b455317d762bb1378aeac3679f3#instructions

inFiles=high/*.jpg
if [ ! -z "$1" ]; then
  inFiles="$1"
fi

outDir=cleanHigh
if [ ! -z "$2" ]; then
  outDir="$2"
fi

fetchCleaner(){
  if [ ! -f "textcleaner" ]; then
    # http://www.fmwconcepts.com/imagemagick/textcleaner/index.php
    wget -o textcleaner http://www.fmwconcepts.com/imagemagick/downloadcounter.php?scriptname=textcleaner&dirname=textcleaner
    chmod +x textcleaner
  fi
}

fetchJb2(){
  if ! [ -x "$(command -v jbig2)" ]; then
    sudo apt install autotools-dev automake libtool libleptonica-dev
    git clone https://github.com/agl/jbig2enc
    cd jbig2enc
    ./autogen.sh
    ./configure && make
    sudo make install
    cd ..
  fi
}

cleanBg(){
  fetchCleaner
  mkdir -p $outDir
  for page in ${inFiles}; do
    echo $page
    file=$(basename $page)
    ./textcleaner -s 2 $page $outDir/$file.gif
  done
}

jb2Encode(){
  fetchJb2
  mkdir -p $outDir
  for page in ${inFiles}; do
    echo $page
    file=$(basename $page)
    jbig2 -t 0.9 -T 150 -O $outDir/$file.jb2 $page
  done
}


#./textcleaner images/wilberforceshenr0000davi_0469.jpg wilberforceshenr0000davi_0469.tiff
