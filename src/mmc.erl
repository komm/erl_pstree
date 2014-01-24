-module(mmc).
-author('komm@siphost.su').

-export([s/0, s/1, start/0, start/1, pstree/1, pstree_struct/1]).

name(Pid, {registered_name,List})->
  name(Pid, List);
name(Pid, []) -> 
  pid_to_list(Pid);
name(_Pid, Name) when is_atom(Name) ->
  atom_to_list(Name)
.

name_struct(Pid, {registered_name,List})->
  name_struct(Pid, List);
name_struct(Pid, []) -> 
  pid_to_list(Pid);
name_struct(_Pid, Name) when is_atom(Name) ->
  atom_to_list(Name)
.

links(Pid, {links,List})->
  links(Pid, List);
links(_, [])->
  [];
links(Pid, [Link|Links])->
  case ets:lookup(mmc, Pid) of
  [{_, Link, 0}]-> 
        ets:update_element(mmc, Pid, {3, 1}),
        [pstree(Link)|links(Pid, Links)]
  ;
  [{_, Link, _}]-> 
        error_logger:info_report([found_group_leader, Pid, Link]), 
        [];
  _ -> [pstree(Link)|links(Pid, Links)]
  end
.

links_struct(Pid, {links,List})->
  links_struct(Pid, List);
links_struct(_, [])->
  [];
links_struct(Pid, [Link|Links])->
  case ets:lookup(mmc, Pid) of
  [{_, Link, 0}]-> 
        ets:update_element(mmc, Pid, {3, 1}),
        [pstree_struct(Link)|links_struct(Pid, Links)]
  ;
  [{_, Link}] -> 
        error_logger:info_report([found_group_leader, Pid, Link]), 
        [];
  _ -> [pstree_struct(Link)|links_struct(Pid, Links)]
  end
.

visual(_GlobalPrefix, _LocalPrefix, [])-> ok;
visual(GlobalPrefix, LocalPrefix, [ {struct, [{Pid, LinkedPid}]} | Tail])->
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
pstree(Port) when is_port(Port)->
  {name, PortName} = rpc:call(node(Port),erlang,port_info,[Port, name]),
  {"<PORT: "++PortName ++ ">",[[]]};
pstree(Pid) when is_pid(Pid)->
  {group_leader, GroupLeader} = rpc:call(node(Pid),erlang,process_info,[Pid, group_leader]),
  case {ets:lookup(mmc, Pid), true} of
  {[], true} -> 
    ets:insert(mmc, {Pid, GroupLeader, 0}),
    case rpc:call(node(Pid), erlang, process_info, [Pid]) of
      undefined -> {process_undefined, [[]]};
      {badrpc,nodedown} -> {process_undefined, [[]]};
      _Parameters ->
        {
            name(Pid, rpc:call(node(Pid),erlang,process_info,[Pid, registered_name])),
            links(Pid, rpc:call(node(Pid),erlang,process_info,[Pid, links]))
        }
    end;
  _ -> []
  end
.

pstree_struct(Port) when is_port(Port)->
  {name, PortName} = rpc:call(node(Port),erlang,port_info,[Port, name]),
  {struct, [{"<PORT: "++PortName ++ ">",[[]]}]};
pstree_struct(Pid) when is_pid(Pid)->
  {group_leader, GroupLeader} = rpc:call(node(Pid),erlang,process_info,[Pid, group_leader]),
  case {ets:lookup(mmc, Pid), true} of
  {[], true} -> 
    ets:insert(mmc, {Pid, GroupLeader, 0}),
    case rpc:call(node(Pid), erlang, process_info, [Pid]) of
    undefined -> 
        {process_undefined, [[]]};
    {badrpc,nodedown} -> 
        {process_undefined, [[]]};
    _Parameters ->
        {struct, [
          { name_struct(Pid, rpc:call(node(Pid),erlang,process_info,[Pid, registered_name])),
            links_struct(Pid, rpc:call(node(Pid),erlang,process_info,[Pid, links]))
          }
        ]}
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
  Tree = pstree_struct(Pid),
  visual("", "", [Tree]),
  ets:delete(mmc),
  ok
.
