-module(ms_player).

-behaviour(gen_server).

-export([start_link/1]).

-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

-record(state, {sock, roomid, roompid}).

start_link(Socket) ->
    gen_server:start_link(?MODULE, [Socket], []).

init([Socket]) ->
    {ok, #state{sock=Socket}}.

handle_call(Msg, _From, State) ->
    NewState =
    case Msg of
        {join, RoomId, RoomPid} ->
            State#state{roomid = RoomId, roompid = RoomPid};    
        {broadcast, Data} ->
            io:format("player broadcast~n"),
            gen_tcp:send(State#state.sock, Data),
            State;
        _Other ->
            State
    end,
    {reply, ok, NewState}.

handle_cast(_Msg, State) ->
    {noreply, State}.

handle_info({tcp, Sock, Data}, #state{roompid = RoomPid} = State) ->
    inet:setopts(Sock, [{active, once}]),
    gen_server:cast(RoomPid, {broadcast, Data}),
    {noreply, State};
handle_info({tcp_closed, _}, State) ->
    {stop, normal, State};
handle_info({tcp_error, _, _Reason}, State) ->
    {stop, normal, State};
handle_info(timeout, State) ->
    {stop, normal, State}.
    
terminate(_Reason,  #state{roompid = RoomPid} = State) ->
    gen_server:cast(RoomPid, {remove, self()}),
    gen_tcp:close(State#state.sock),
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

									     
