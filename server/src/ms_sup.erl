-module(ms_sup).

-behaviour(supervisor).

-export([start_link/0]).

-export([init/1]).

start_link() ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, []).

init([]) ->
    AcceptServer = {
      ms_accept, {ms_accept, start_link, []},
      permanent, 2000, worker, [ms_accept]
     },

    Restart = {one_for_one, 5, 10},
    {ok, {Restart, [AcceptServer]}}.
    
