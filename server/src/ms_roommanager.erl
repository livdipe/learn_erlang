-module(ms_roommanager).

-behaviour(gen_server).

-export([start_link/0]).

-export([init/1,
        handle_call/3,
        handle_cast/2,
        handle_info/2,
        terminate/2,
        code_change/3]).

-export([join/1]).

-record(state, {rooms}).

start_link() ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

join(PlayerSocket) ->
    {ok, PlayerPid} = ms_player_sup:create_player(PlayerSocket),
    gen_tcp:controlling_process(PlayerSocket, PlayerPid),
    gen_server:call(?MODULE, {join, PlayerPid, PlayerSocket}).

init([]) ->
    {ok, #state{}}.

handle_call({join, PlayerPid, PlayerSocket}, _From, #state{rooms = Rooms} = State) ->
    NewState = 
    case Rooms of
       undefined ->
            {ok, RoomPid} = ms_room_sup:create_room(PlayerPid, 1),
            gen_server:call(PlayerPid, {join, 1, RoomPid}),
            gen_server:call(RoomPid, {join, PlayerPid, PlayerSocket}),
            State#state{rooms = [RoomPid]};
       [RoomPid | _ElseRooms] ->
            gen_server:call(PlayerPid, {join, 1, RoomPid}),
            gen_server:call(RoomPid, {join, PlayerPid, PlayerSocket}),
            State;
       [] ->
            %% 1 roomid
            {ok, RoomPid} = ms_room_sup:create_room(PlayerPid, 1),
            gen_server:call(PlayerPid, {join, 1, RoomPid}),
            gen_server:call(RoomPid, {join, PlayerPid, PlayerSocket}),
            State#state{rooms = [RoomPid]}
    end,
    {reply, ok, NewState}.

handle_cast(stop, State) ->
    {stop, normal, State}.

handle_info(_Info, State) ->
    {noreply, State}.

terminate(_Reason, _State) ->
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.
