#!/bin/bash

# Fix bad routes in suite files due malfunction in firefox IDE 
sed -i 's/\.\.\/\.\.\/\.\.\/\.\.\/\.\.\//\.\.\//g' suites/*
