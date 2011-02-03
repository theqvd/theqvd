#!/bin/bash

ASCIIDOC_EXT=txt

HTML_DIR=../html
PDF_DIR=../pdf
DOCBOOK_DIR=../docbook
WORDPRESS_DIR=../wordpress

HTML_EXT=html
PDF_EXT=pdf
DOCBOOK=xml

ICONS_DIR=../images/icons

# MAIN

for f in $*;
do
    echo "Processing $f file.."
    asciidoc -a numbered -a icons -a toc -a toctitle=INDEX -a toclevel=3 -a numbered -o $HTML_DIR/$f.html $f
done

exit 0
