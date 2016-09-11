-module(ms_accept_sup).

-behaviour(supervisor).

-export([start_link/1,
        start_child/0]).

-export([init/1]).

-define(SERVER, ?MODULE).

start_link(LSock) -> 
    supervisor:start_link({local, ?SERVER}, ?MODULE, [LSock]).

start_child() ->
    supervisor:start_child(?SERVER, []).

init([LSock]) ->
    Server = {ms_accept, {ms_accept, start_link, [LSock]},
              temporary, brutal_kill, worker, [ms_accept]},
    Children = [Server],
    RestartStrategy = {simple_one_for_one, 0, 1},
    {ok, {RestartStrategy, Children}}.
    

