#!/bin/bash

# post processing for Archive.org books:
# https://gist.github.com/cemerson/043d3b455317d762bb1378aeac3679f3#instructions

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

inDir=high

inFiles=${inDir}/*.jpg
if [ ! -z "$2" ]; then
  inFiles="$2"
fi

outDir=out
if [ ! -z "$3" ]; then
  outDir="$3"
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

jb2Pdf(){
  pdfMerge $outDir/jb2
}

ocrPdf(){
  local pdfDir="$outDir/pdfjb2"
  local ocrDir="$outDir/ocr"
  local page file

  if ! command -v ocrmypdf >/dev/null 2>&1; then
    echo "ocrmypdf not found" >&2
    return 1
  fi

  mkdir -p "$ocrDir"
  for page in "$pdfDir"/*.pdf; do
    file=$(basename "$page")
    echo "OCR: $page"
    rm -f "$ocrDir/$file"
    if ! ocrmypdf --output-type pdf --optimize 0 -l "${OCR_LANG:-eng}" \
      "$page" "$ocrDir/$file"; then
      return 1
    fi
  done

  bookOut="$outDir/$book-jb2-ocr.pdf"
  pdfunite "$ocrDir"/*.pdf "$bookOut"
  echo "Searchable PDF created: $bookOut"
}

pdfMerge(){
  inDir=$1
  what=$(basename $inDir)
  mkdir -p $outDir/pdf$what
  for page in ${inDir}/*; do
    echo $page
    file=$(basename $page)
    convert $page $outDir/pdf$what/${file}.pdf
  done
  bookOut=$outDir/$book-$what.pdf
  pdfunite $outDir/pdf$what/*.pdf $bookOut
  echo "PDF created: $bookOut"
}

jb2Book(){
  jb2Encode
  jb2Pdf
}

first=$(echo ${inFiles} | cut -d ' ' -f 1)
book=$(basename ${first%.*})
echo "book: $book"


if [ "$1" == "jb2" ]; then
  jb2Book
elif [ "$1" == "ocr" ]; then
  ocrPdf
else
  echo "Usage: $0 [jb2|ocr]"
fi