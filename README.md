# erl_pstree

Erlang process tree tools. (as *NIX pstree)

## Usage

### 1. Compile

**TODO**

### 2. Run

### Start with shell script

### Usage from erlang cli

    mmc:s()
    mmc:s(Pid :: list() | pid())

### Usage via http request

**Request**

    GET /tree.json


**Response (in json)**

    {
      "pid_name":[
        { "pid_name1" : [ {"pid_name3":""}, ... ]},
        { "pid_name2" : "" }
        ...
      ]
    }

## Runtime dependencies

* [Erlang R16B](http://www.erlang.org/)

## Development dependencies

* [Erlang R16B](http://www.erlang.org/)
* [Slim](http://slim-lang.com/)
* [Sass](http://sass-lang.com/)
* [Coffeescript](http://coffeescript.org/)
