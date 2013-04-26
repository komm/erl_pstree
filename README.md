erl_pstree
==========

Erlang process tree tools. (as *NIX pstree)

Usage from erlang cli:
  mmc:s() 
  mmc:s(Pid :: list() | pid())

Usage from http-json:
GET /tree.json HTTP/1.0

HTTP/1.1 200 OK
Server: nginx/0.8.53
Content-Type: application/json

{
  "pid_name":[
    { "pid_name1" : [ {"pid_name3":""}, ... ]},
    { "pid_name2" : "" }
    ...
  ]
}


