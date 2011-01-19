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

generate_html () {
	asciidoc -a numbered -a icons -a iconsdir=$ICONS_DIR -a toc -a toctitle=INDEX -a toclevel=3  -a numbered -o $HTML_DIR/$1.$HTML_EXT $1.$ASCIIDOC_EXT
}

generate_wordpress () {
	asciidoc -a numbered -a icons -a iconsdir=$ICONS_DIR -a toc -a toctitle=INDEX -a toclevel=3 -a numbered -b wordpress -o $WORDPRESS_DIR/$1.$HTML_EXT $1.$ASCIIDOC_EXT
}

generate_docbook ()  {
	asciidoc -a numbered -a icons -a iconsdir=$ICONS_DIR -a toc -a toctitle=INDEX -a numbered -b docbook -t book -o $DOCBOOK_DIR/$1.$DOCBOOK_EXT $2.$ASCIIDOC_EXT
}


# MAIN
if [ ! -f $2.txt ]
then 
	echo "No valid input files $2.$ASCIIDOC_EXT" 
	echo "Usage $0 web|docbook|pdf|all document.$ASCIIDOC_EXT"
	exit 1 
fi

case $1 in

	web )
	generate_html $2
	;;
	
	docbook )
	generate_docbook $2
	;;

	pdf )
	generate_pdf $2
	;;

	wordpress )
	generate_wordpress $2
	;;

	all )
	generate_html $2
	generate_docbook $2
	generate_pdf $2
	;;	

	*)
	echo "Usage $0 web|docbook|pdf|all document.$ASCIIDOC_EXT"
	;;
	
esac

exit 0
