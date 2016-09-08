-module(ms_room_sup).

-behaviour(supervisor).

-export([start_link/0,
		create_room/2]).

-export([init/1]).

-define(CHILD(Id, Mod, Type, Args), {Id, {Mod, start_link, Args}, temporary, brutal_kill, Type, [Mod]}).

start_link() ->
	supervisor:start_link({local, ?MODULE}, ?MODULE, []).

create_room(OwnerPid, RoomId) ->
	io:format("create room~n"),
	supervisor:start_child(?MODULE, [OwnerPid, RoomId]).

init([]) ->
	{ok, {{simple_one_for_one, 0, 1}, 
		[?CHILD(ms_room, ms_room, worker, [])]
	}}.
