-module(handle_pstree).
-author('komm@siphost.su <Dmitry komm Karpov>').

-behaviour(cowboy_http_handler).
-export([init/3]).
-export([handle/2]).
-export([terminate/3]).
 
init({tcp, http}, Req, Opts) ->
    {ok, Req, undefined_state}.
 
handle(Req, State) ->
    Resp = cowboy_req:path(Req),
    ets:new(mmc,[ set , public,named_table]),
    {ok, Req2} = cowboy_req:reply(200, [], iolist_to_binary(mochijson2:encode(mmc:pstree_struct(list_to_pid("<0.0.0>")))), Req),
    ets:delete(mmc),
    {ok, Req2, State}.
 
terminate(Reason, Req, State) ->
    ok.
