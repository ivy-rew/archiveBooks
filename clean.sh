#!/bin/bash

# post processing for Archive.org books:
# https://gist.github.com/cemerson/043d3b455317d762bb1378aeac3679f3#instructions

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

inDir=high

inFiles=${inDir}/*.jpg
if [ ! -z "$1" ]; then
  inFiles="$1"
fi

outDir=out
if [ ! -z "$2" ]; then
  outDir="$2"
fi

echo "archive tools: $DIR"

fetchCleaner(){
  if [ ! -f "$DIR/textcleaner" ]; then
    # http://www.fmwconcepts.com/imagemagick/textcleaner/index.php
    uri=http://www.fmwconcepts.com/imagemagick/downloadcounter.php?scriptname=textcleaner&dirname=textcleaner
    wget -o "$DIR/textcleaner" "$uri"
    sudo chmod +x "$DIR/textcleaner"
  fi
}

fetchJb2(){
  if ! [ -x "$(command -v jbig2)" ]; then
    sudo apt install autotools-dev automake libtool libleptonica-dev
    where=$PWD
    cd $DIR
    git clone https://github.com/agl/jbig2enc
    cd jbig2enc
    ./autogen.sh
    ./configure && make
    sudo make install
    cd $where
  fi
}

cleanBg(){
  fetchCleaner
  mkdir -p $outDir/clean
  for page in ${inFiles}; do
    echo $page
    file=$(basename $page)
    $DIR/textcleaner -s 2 $page $outDir/clean/$file.gif
  done
}

jb2Encode(){
  fetchJb2
  mkdir -p $outDir/jb2
  for page in ${inFiles}; do
    echo $page
    file=$(basename $page)
    jbig2 -t 0.9 -T 150 -O $outDir/jb2/$file.jb2 $page
  done
}


#./textcleaner images/wilberforceshenr0000davi_0469.jpg wilberforceshenr0000davi_0469.tiff
