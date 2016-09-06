-module(ms_player_sup).

-behaviour(supervisor).

-export([start_link/0,
	 create_player/1]).

-export([init/1]).

-define(CHILD(Id, Mod, Type, Args), {Id, {Mod, start_link, Args},
				     temporary, brutal_kill, Type, [Mod]}).

start_link() ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, []).

create_player(Sock) ->
    supervisor:start_child(?MODULE, [Sock]).

init([]) ->
    {ok, {{simple_one_for_one, 0, 1},
	  [?CHILD(ms_player, ms_player, worker, [])]
	  }}.

