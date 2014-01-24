
-module(pstree_sup).

-behaviour(supervisor).

%% API
-export([start_link/0]).

%% Supervisor callbacks
-export([init/1]).

%% Helper macro for declaring children of supervisor
-define(CHILD(I, Type), {I, {I, start_link, []}, permanent, 5000, Type, [I]}).

%% ===================================================================
%% API functions
%% ===================================================================

start_link() ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, []).

%% ===================================================================
%% Supervisor callbacks
%% ===================================================================

init([]) ->
    application:start(crypto),
    application:start(ranch),
    application:start(cowlib),
    application:start(cowboy),
    application:start(mimetypes),
    Dispatch = cowboy_router:compile([
       %% {URIHost, list({URIPath, Handler, Opts})}
       {'_', [{'_', handle_pstree, []}]}
    ]),
    cowboy:start_http(http_tree_listner, 100, [{port, 8080}], [{env, [{dispatch, Dispatch}]}]),
    {ok, { {one_for_one, 5, 10}, []} }.

