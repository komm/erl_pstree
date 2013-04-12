-module(mmc).
-author('komm@siphost.su').

-export([start/0, start/1, pstree/1, visual/3]).

name(Pid, {registered_name,List})->
  name(Pid, List);
name(Pid, []) -> 
  pid_to_list(Pid);
name(Pid, Name) when is_atom(Name) ->
  atom_to_list(Name)
.

links(Pid, {links,List})->
  links(Pid, List);
links(Pid, [])->
  [];
links(Pid, [Link|Links])->
  case ets:lookup(mmc, Pid) of
  [{Pid, Link}] -> [];
  _ -> [pstree(Link)|links(Pid, Links)]
  end
.

visual(GlobalPrefix, LocalPrefix, [])-> ok;
visual(GlobalPrefix, LocalPrefix, [ {Pid, LinkedPid} | Tail])->
	case LinkedPid of
	[[]] -> 
		io:format('~s~s+---~s~n',[GlobalPrefix, LocalPrefix, Pid]),
		visual(GlobalPrefix, LocalPrefix, Tail);
	PidList when is_list(PidList)->
		io:format('~s~s+---~s---+~n',[GlobalPrefix, LocalPrefix, Pid]),
		NewGlobalPrefix = 
		case Tail of
		[] -> GlobalPrefix ++ lists:map(fun(C)-> $\  end, LocalPrefix);
		[[]] -> GlobalPrefix ++ lists:map(fun(C)-> $\  end, LocalPrefix);
		_ -> 
			GlobalPrefix ++ lists:map(fun(C)->$\  end, LocalPrefix) ++ [$|]
		end,
		visual(NewGlobalPrefix, lists:duplicate(length(Pid)+7," "), LinkedPid),
		%%visual(NewGlobalPrefix, lists:duplicate(length(Pid)+6," ") ++ ["+---"], LinkedPid),
		visual(GlobalPrefix, LocalPrefix, Tail);
	_ -> visual(GlobalPrefix, LocalPrefix, Tail)
	end
;
visual(GlobalPrefix, LocalPrefix, [ _ | Tail])->
	visual(GlobalPrefix, LocalPrefix, Tail)
.

-spec pstree(Pid :: list() | pid())-> process_undefined | term().
pstree(Pid) when is_port(Pid)->
  {"<PORT>",[[]]};
pstree(Pid) when is_pid(Pid)->
  {group_leader, GroupLeader} = erlang:process_info(Pid,group_leader),
  case {ets:lookup(mmc, Pid), true} of
  {[], true} -> 
    ets:insert(mmc, {Pid, GroupLeader}),
    case erlang:process_info(Pid) of
      undefined -> process_undefined;
      Parameters ->
        {name(Pid, erlang:process_info(Pid, registered_name)),
  	  links(Pid, erlang:process_info(Pid, links))
        }
    end;
  _ -> []
  end
.

-spec start()-> term().
-spec start(Pid :: list() | pid())-> term().
start()->
  start(self()).
start(Pid) when is_list(Pid)->
  start(list_to_atom(Pid));
start(Pid) when is_pid(Pid)->
  ets:new(mmc,[ set , public,named_table]),
  Tree = pstree(Pid),
%%  io:format('---',[]),
  visual("", "", [Tree]),
  ets:delete(mmc)

.
