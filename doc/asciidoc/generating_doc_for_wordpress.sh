#!/bin/bash

ASCIIDOC_EXT=txt

HTML_DIR=../html/en
PDF_DIR=../pdf
DOCBOOK_DIR=../docbook
WORDPRESS_DIR=../wordpress

HTML_EXT=html
PDF_EXT=pdf
DOCBOOK=xml

ICONS_DIR=../images/icons

# MAIN

folders="licenses operations overview installation"

for i in $folders
do
    for f in ./en/$i/*
    do
	echo "Processing $f"
	fb=$(basename $f)
	#echo "Processing $fb"
	asciidoc -a numbered -a icons -a iconsdir=$ICONS_DIR -a toc -a toctitle=INDEX -a toclevel=3 -a numbered -o $HTML_DIR/$i/$fb.html $f
    done

done

exit 0
