-module(handle_pstree).
-author('komm@siphost.su <Dmitry komm Karpov>').

-behaviour(cowboy_http_handler).
-export([init/3]).
-export([handle/2]).
-export([terminate/3]).
 
init({tcp, http}, Req, Opts) ->
    {ok, Req, undefined_state}.
 
handle(Req, State) ->
    io:format('~w~n', [cowboy_req:path(Req)]),
    case cowboy_req:path(Req) of
    {<<"/tree.json">> = Filename, _} -> 
	    ets:new(mmc,[ set , public,named_table]),
	    {ok, Req2} = cowboy_req:reply(200, [{<<"content-type">>, <<"application/json">>}], iolist_to_binary(mochijson2:encode(mmc:pstree_struct(list_to_pid("<0.0.0>")))), Req),
	    ets:delete(mmc),
	    {ok, Req2, State};
    {URI, _} -> 
	    Docroot = 
	    case lists:keyfind(webroot,1,init:get_arguments()) of
		false -> "www";
		{webroot,[Path]}-> Path
	    end,
	    Filename = filename:join([Docroot, binary_to_list(URI) -- "/"]),
	    Mimetype = mimetypes:filename(Filename),
	    {ok, Req2} = 
	    case file:read_file(Filename) of
		{error, _} -> cowboy_req:reply(404, [], <<"File not found">>, Req);
		{ok, Body} -> cowboy_req:reply(200, [{<<"content-type">>, Mimetype}], Body, Req)
	    end,
	    io:format('Docroot=~p~nFilename= ~p~n',[Docroot, Filename]),
	    {ok, Req2, State};

    _ ->    {ok, Req2} = cowboy_req:reply(404, [], <<"404 not found">>, Req),
	    {ok, Req2, State}
    end
.
 
terminate(Reason, Req, State) ->
    ok.
