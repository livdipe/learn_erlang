-module(ms_room).

-behaviour(gen_server).

-export([start_link/2]).

-export([init/1,
		handle_call/3,
		handle_cast/2,
		handle_info/2,
		terminate/2,
		code_change/3]).

-record(player, {id, pid, sock, position}).
-record(state, {roomid, owner, players=[]}).

start_link(OwnerPid, RoomId) ->
	gen_server:start_link(?MODULE, [OwnerPid, RoomId], []).

init([OwnerPid, RoomId]) -> 
    {ok, #state{roomid = RoomId, owner = OwnerPid}}.

handle_call(Msg, _From, #state{players = Players} = State) ->
    NewState = 
    case Msg of
        {join, PlayerPid, PlayerSocket} ->
            NewId = get_new_id(Players),
            notify(PlayerSocket, list_to_binary(io_lib:format("createplayer,~p",[NewId]))),
            notify_other_info(PlayerSocket, Players),
            NewPlayer = #player{id = NewId, pid = PlayerPid, sock = PlayerSocket},
            NewPlayers = [NewPlayer | Players],
            %% 广播其他玩家，有新玩家加入 
            Str = io_lib:format("newplayer,~p", [NewId]),
            Data = list_to_binary(Str),
            broadcast(Data, Players),
            State#state{players=NewPlayers};
        _ ->
            State
    end,
    {reply, ok, NewState};
handle_call(_Request, _From, State) ->
    {reply, ok, State}.

handle_cast(Msg, #state{players = Players} = State) ->
    NewState = 
    case Msg of
        {remove, PlayerPid} ->
            io:format("remove ~p from room, left ~p~n", [PlayerPid, length(Players) - 1]),
            State#state{players = lists:keydelete(PlayerPid, #player.pid, Players)};
        {broadcast, Data} ->
            broadcast(Data, Players),
            State;
        _ ->
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
    fun(Player) ->
            notify(Player#player.sock, Data)
		end,
		Players
		),
	ok.

notify(PlayerSocket, Data) ->
    gen_tcp:send(PlayerSocket, Data).

notify_other_info(PlayerSocket, OtherPlayers) ->
    lists:foreach(
      fun(Player) ->
        notify(PlayerSocket, list_to_binary(io_lib:format("newplayer,~p",[Player#player.id])))
      end,
      OtherPlayers
     ),
    ok.

get_new_id(Players) ->
    get_new_id(1, Players).

get_new_id(Id, []) ->
    Id;
get_new_id(Id, [Player|Players]) ->
    NewId = if
                Id > Player#player.id ->
                    Id;
                true ->
                    Player#player.id + 1
            end,
    get_new_id(NewId, Players).
