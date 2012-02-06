#!/bin/bash

dirbase=$(dirname $0)
ASCIIDOC_EXT=txt

HTML_DIR=$dirbase/../html
PDF_DIR=$dirbase/../pdf
DOCBOOK_DIR=$dirbase/../docbook
WORDPRESS_DIR=$dirbase/../wordpress

HTML_EXT=html
PDF_EXT=pdf
DOCBOOK_EXT=xml

ICONS_DIR=$dirbase/../images/icons

die() {
    echo "$@"
    exit 1
}

generate_html () {
	asciidoc -a numbered -a icons -a iconsdir=$ICONS_DIR -a toc -a toctitle=INDEX -a toclevel=3  -a numbered -o $HTML_DIR/$1.$HTML_EXT $1.$ASCIIDOC_EXT
}

generate_wordpress () {
	asciidoc -a numbered -a icons -a iconsdir=$ICONS_DIR -a toc -a toctitle=INDEX -a toclevel=3 -a numbered -b wordpress -o $WORDPRESS_DIR/$1.$HTML_EXT $1.$ASCIIDOC_EXT
}

generate_docbook ()  {
	asciidoc -a numbered -a icons -a iconsdir=$ICONS_DIR -a toc -a toctitle=INDEX -a toclevel=3 -a numbered -b docbook -o $DOCBOOK_DIR/$1.$DOCBOOK_EXT $1.$ASCIIDOC_EXT
}

generate_pdf ()  {
    which xsltproc > /dev/null || die "Please install xsltproc for pdf generation"
    which dblatex > /dev/null || die "Please install dblatex for pdf generation"
    a2x --destination-dir=$PDF_DIR --icons-dir=$ICONS_DIR $1.$ASCIIDOC_EXT
}

# MAIN
if [ ! -f $2.txt ]
then 
    if [ -f $2 ]
    then
	file=${2%.$ASCIIDOC_EXT}
    else
	die "No valid input files $2.$ASCIIDOC_EXT
Usage $0 web|docbook|pdf|all document.$ASCIIDOC_EXT"
    fi
else
    file=$2
fi


case $1 in

	web )
	generate_html $file
	;;
	
	docbook )
	generate_docbook $file
	;;

	pdf )
	generate_pdf $file
	;;

	wordpress )
	generate_wordpress $file
	;;

	all )
	generate_html $file
	generate_docbook $file
	generate_pdf $file
	;;	

	*)
	echo "Usage $0 web|docbook|pdf|all document.$ASCIIDOC_EXT"
	;;
	
esac

exit 0
