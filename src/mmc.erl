-module(mmc).
-author('komm@siphost.su').

-export([s/0, s/1, start/0, start/1, pstree/1]).

name(Pid, {registered_name,List})->
  name(Pid, List);
name(Pid, []) -> 
  pid_to_list(Pid);
name(_Pid, Name) when is_atom(Name) ->
  atom_to_list(Name)
.

links(Pid, {links,List})->
  links(Pid, List);
links(_, [])->
  [];
links(Pid, [Link|Links])->
  case ets:lookup(mmc, Pid) of
  [{_, Link}] -> [];
  _ -> [pstree(Link)|links(Pid, Links)]
  end
.

visual(_GlobalPrefix, _LocalPrefix, [])-> ok;
visual(GlobalPrefix, LocalPrefix, [ {Pid, LinkedPid} | Tail])->
  case LinkedPid of
  [[]] -> 
    io:format('~s~s+---~s~n',[GlobalPrefix, LocalPrefix, Pid]);
  PidList when is_list(PidList)->
    io:format('~s~s+---~s---+~n',[GlobalPrefix, LocalPrefix, Pid]),
    [NewGlobalPrefix, Diff] = 
    case Tail of
    [] -> [GlobalPrefix ++ lists:map(fun(_)-> $\  end, LocalPrefix), 1];
    [[]] -> [GlobalPrefix ++ lists:map(fun(_)-> $\  end, LocalPrefix), 1];
    _ -> 
      [GlobalPrefix ++ lists:map(fun(_)->$\  end, LocalPrefix) ++ [$|], 0]
    end,
    visual(NewGlobalPrefix, lists:duplicate(length(Pid)+6+Diff," "), LinkedPid);
  _ -> ok
  end,
  visual(GlobalPrefix, LocalPrefix, Tail)
;
visual(GlobalPrefix, LocalPrefix, [ _ | Tail])->
  visual(GlobalPrefix, LocalPrefix, Tail)
.

-spec pstree(Pid :: list() | pid())-> process_undefined | term().
pstree(Pid) when is_port(Pid)->
  {"<PORT>",[[]]};
pstree(Pid) when is_pid(Pid)->
  {group_leader, GroupLeader} = rpc:call(node(Pid),erlang,process_info,[Pid, group_leader]), %%erlang:process_info(Pid,group_leader),
  case {ets:lookup(mmc, Pid), true} of
  {[], true} -> 
    ets:insert(mmc, {Pid, GroupLeader}),
    case rpc:call(node(Pid), erlang, process_info, [Pid]) of
      undefined -> {process_undefined, [[]]};
      {badrpc,nodedown} -> {process_undefined, [[]]};
      _Parameters ->
        {name(Pid, rpc:call(node(Pid),erlang,process_info,[Pid, registered_name])),
        %%{name(Pid, erlang:process_info(Pid, registered_name)),
  	  %%links(Pid, erlang:process_info(Pid, links))
  	  links(Pid, rpc:call(node(Pid),erlang,process_info,[Pid, links]))
        }
    end;
  _ -> []
  end
.

-spec s()-> ok.
-spec s(Pid :: list() | pid())-> ok.
s()-> start().
s(Pid)-> start(Pid).

-spec start()-> ok.
-spec start(Pid :: list() | pid())-> ok.
start()->
  start(self()).
start(Pid) when is_list(Pid)->
  start(list_to_pid(Pid));
start(Pid) when is_pid(Pid)->
  ets:new(mmc,[ set , public,named_table]),
  Tree = pstree(Pid),
  visual("", "", [Tree]),
  ets:delete(mmc),
  ok
.
