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
    io:format("room pid : ~p~n", [self()]),
	{ok, #state{roomid = RoomId, owner = OwnerPid}}.

handle_call(_Request, _From, State) ->
    {reply, ok, State}.


%% 房间中广播消息
%handle_cast({broadcast, Data}, State) ->
%    io:format("broadcast~n"),
%    broadcast(Data, State#state.players),
%    {noreply, State};

%% 房间中加入玩家
%handle_cast({join, PlayerPid}, State) ->
    %io:format("~p join~n", [PlayerPid]),
    %NewPlayers = [PlayerPid | State#state.players],
    %{noreply, ok, State#state{players=NewPlayers}};
handle_cast(Msg, State) ->
    io:format("Msg:~p~n", [Msg]),
    NewState = 
    case Msg of
        {join, PlayerPid} ->
            io:format("~p join~n", [PlayerPid]),
            NewPlayers = [PlayerPid | State#state.players],
            State#state{players=NewPlayers};
        {broadcast, Data} ->
            io:format("okdkdk~n"),
            broadcast(Data, State#state.players),
            State;
        _ ->
            io:format("erjek~n"),
            State
    end,
    {noreply, NewState}.


handle_info(_Info, State) ->
	{noreply, State}.

terminate(_Reason, _State) ->
	ok.

code_change(_OldVsn, State, _Extra) ->
	{ok, State}.


broadcast(Data, Players) ->
	lists:foreach(
		fun(PlayerPid) ->
            io:format("broadcast to player : ~p~n", [PlayerPid]),
            gen_server:cast(PlayerPid, Data)
		end,
		Players
		),
	ok.





