#!/bin/bash

# post processing for Archive.org books:
# https://gist.github.com/cemerson/043d3b455317d762bb1378aeac3679f3#instructions

inFiles=hgih/*.jpg
outDir=cleanHigh

if [ ! -f "textcleaner" ]; then
  # http://www.fmwconcepts.com/imagemagick/textcleaner/index.php
  wget -o textcleaner http://www.fmwconcepts.com/imagemagick/downloadcounter.php?scriptname=textcleaner&dirname=textcleaner
  chmod +x textcleaner
if

mkdir -p $outDir
for page in "${inFiles}"; do
  echo $page
  file=$(basename $page)
  ./textcleaner -s 2 $page $outDir/$file.gif
done

#./textcleaner images/wilberforceshenr0000davi_0469.jpg wilberforceshenr0000davi_0469.tiff
