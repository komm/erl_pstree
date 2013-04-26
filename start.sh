#!/bin/bash

erl -pa ebin -pa deps/*/ebin -webroot ${$1-$PWD/www}

