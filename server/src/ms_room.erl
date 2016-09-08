-module(ms_room).

-behaviour(gen_server).

-export([start_link/2]).

-export([init/1,
		handle_call/3,
		handle_cast/2,
		handle_info/2,
		terminate/2,
		code_change/3]).

-record(state, {roomid, owner, players=[]}).

start_link(OwnerPid, RoomId) ->
	gen_server:start_link(?MODULE, [OwnerPid, RoomId], []).

init([OwnerPid, RoomId]) ->
	{ok, #state{roomid = RoomId, owner = OwnerPid}}.

handle_call({join, PlayerPid}, _From, #state{players=Players} = State) ->
	io:format("~p join~n", [PlayerPid]),
	NewPlayers = [PlayerPid | Players],
	{reply, ok, State#state{players=NewPlayers}}.

handle_cast({broadcast, Data}, #state{players=Players} = State) ->
	broadcast(Data, Players),
	{noreply, State}.

handle_info(_Info, State) ->
	{noreply, State}.

terminate(_Reason, _State) ->
	ok.

code_change(_OldVsn, State, _Extra) ->
	{ok, State}.


broadcast(Data, Players) ->
	lists:foreach(
		fun(PlayerPid) ->
			gen_server:cast(PlayerPid, Data)
		end,
		Players
		),
	ok.





