-module(ms_accept).

-behaviour(gen_server).

-export([start_link/1]).

-export([init/1,
	 handle_call/3,
	 handle_cast/2,
	 handle_info/2,
	 terminate/2,
	 code_change/3]).

-record(state, {lsock}).

start_link(LSock) ->
    %% Port = 8765,
    gen_server:start_link(?MODULE, [LSock], []).

init([LSock]) ->
    %% {ok, Sock} = gen_tcp:listen(Port, [binary, {reuseaddr, true}, {active, once},
				       %% {nodelay, true}, {ip, {0, 0, 0, 0}}, inet, {packet, 2}]),
    %% gen_server:cast(self(), accept),
    %% {ok, #state{sock=Sock}}.
    inet:setopts(LSock, [{active, once}, {packet, 2}, binary]),
    {ok, #state{lsock = LSock}, 0}.
				       
handle_call(Msg, _From, State) ->				     
    {reply, {ok, Msg}, State}.

%% handle_cast(accept, #state{sock = Sock, rooms = Rooms} = State) ->
    %% {ok, Client} = gen_tcp:accept(Sock),
    %% io:format("A Client Connected: ~p~n", [Client]),
    %% {ok, PlayerPid} = ms_player_sup:create_player(Client),
    %% gen_tcp:controlling_process(Client, PlayerPid),
    %% NewState = 
    %% case Rooms of
    %%    undefined ->
    %%         {ok, RoomPid} = ms_room_sup:create_room(PlayerPid, 1),
    %%         gen_server:cast(PlayerPid, {join, 1, RoomPid}),
    %%         gen_server:call(RoomPid, {join, PlayerPid, Client}),
    %%         State#state{rooms = [RoomPid]};
    %%    [RoomPid | _ElseRooms] ->
    %%         gen_server:cast(PlayerPid, {join, 1, RoomPid}),
    %%         %% gen_server:cast(RoomPid, {join, PlayerPid, Client}),
    %%         gen_server:call(RoomPid, {join, PlayerPid, Client}),
    %%         %% io:format("~p~n", [Rooms]),
    %%         State;
    %%    [] ->
    %%         %% 1 roomid
    %%         {ok, RoomPid} = ms_room_sup:create_room(PlayerPid, 1),
    %%         gen_server:cast(PlayerPid, {join, 1, RoomPid}),
    %%         %% gen_server:cast(RoomPid, {join, PlayerPid, Client}),
    %%         gen_server:call(RoomPid, {join, PlayerPid, Client}),
    %%         State#state{rooms = [RoomPid]}
    %% end,
    %% gen_server:cast(self(), accept),
    %% {noreply, NewState}.
    %% gen_server:cast(self(), accept),
    %% {noreply, State}.

handle_cast(stop, State) ->
    {stop, normal, State}.

handle_info(timeout, #state{lsock = LSock} = State) ->
    {ok, ClientSocket} = gen_tcp:accept(LSock),
    {ok, {IP, Port}} = inet:peername(ClientSocket),
    io:format("connection from ~p:~p~n", [IP, Port]),
    ms_accept_sup:start_child(),
    ms_roommanager:join(ClientSocket),
    %% {ok, PlayerPid} = roommanager:join(ClientSocket),
    %% gen_tcp:controlling_process(ClientSocket, PlayerPid),
    %% {noreply, State#state{socket = ClientSocket, addr = IP}};
    %% {stop, normal, State};
    {stop, normal, State};
handle_info(_Info, State) ->
    {noreply, State}.

terminate(_Reason, _State) ->
    io:format("ms_accept teminate~n"),
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.
