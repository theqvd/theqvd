#!/bin/bash

for file in *po ; do
    mo=`echo "$file" | sed 's/\.po$/\.mo/'`
    echo "$file => $mo"
    msgfmt $file -o $mo
done
