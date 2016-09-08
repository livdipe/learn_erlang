-module(ms_accept).

-behaviour(gen_server).

-export([start_link/0]).

-export([init/1,
	 handle_call/3,
	 handle_cast/2,
	 handle_info/2,
	 terminate/2,
	 code_change/3]).

-record(state, {sock, rooms}).

start_link() ->
    Port = 8765,
    gen_server:start_link({local, ?MODULE}, ?MODULE, [Port], []).

init([Port]) ->
    {ok, Sock} = gen_tcp:listen(Port, [binary, {reuseaddr, true}, {active, once},
				       {nodelay, true}, {ip, {0, 0, 0, 0}}, inet, {packet, 2}]),
    gen_server:cast(self(), accept),
    {ok, #state{sock=Sock}}.
				       
handle_call(_Request, _From, State) ->				     
    Reply = ok,
    {reply, Reply, State}.

handle_cast(accept, #state{sock = Sock, rooms = Rooms} = State) ->
    {ok, Client} = gen_tcp:accept(Sock),
    io:format("A Client Connected: ~p~n", [Client]),
    {ok, PlayerPid} = ms_player_sup:create_player(Client),
    gen_tcp:controlling_process(Client, PlayerPid),
    NewState = 
    % case State#state.rooms of
    case Rooms /= [] of
        true ->
            [RoomPid | _ElseRooms] = Rooms,
            gen_server:cast(RoomPid, {join, PlayerPid}),
            gen_server:cast(PlayerPid, {join, 1, RoomPid}),
            State;
        false ->
            %% 1 roomid
            {ok, RoomPid} = ms_room_sup:create_room(PlayerPid, 1),
            gen_server:cast(PlayerPid, {join, 1, RoomPid}),
            gen_server:cast(RoomPid, {join, PlayerPid}),
            State#state{rooms = [RoomPid]}
    end,
    gen_server:cast(self(), accept),
    {noreply, NewState}.

handle_info(_Info, State) ->
    {noreply, State}.

terminate(_Reason, State) ->
    gen_tcp:close(State#state.sock),
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.
