#!/bin/bash

echo "Usage: $0 <DOCROOT>"
echo "DOCROOT now: ${1:-$PWD/www}"

erl -pa ebin -pa deps/*/ebin -webroot ${1:-$PWD/www} -s pstree_sup start_link

