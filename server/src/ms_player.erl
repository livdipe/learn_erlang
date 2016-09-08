-module(ms_player).

-behaviour(gen_server).

-export([start_link/1]).

-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

-record(state, {sock, roomid, roompid}).

start_link(Socket) ->
    gen_server:start_link(?MODULE, [Socket], []).

init([Socket]) ->
    % io:format("ms_player init ~p~n", [Socket]),
    % gen_tcp:send(Socket, <<"abc">>),
    {ok, #state{sock=Socket}}.

handle_call(_Request, _From, State) ->
    Reply = ok,
    {reply, Reply, State}.

handle_cast({broadcast, Data}, State) ->
    gen_tcp:send(State#state.sock, Data),
    {noreply, State};
handle_cast({join, RoomId, RoomPid}, State) ->
    {noreply, State#state{roomid = RoomId, roompid = RoomPid}};    
handle_cast(_Msg, State) ->
    {noreply, State}.

handle_info({tcp, Sock, Data}, State) ->
    io:format("receive Data ~p~n", [Data]),
    inet:setopts(Sock, [{active, once}]),
    % gen_tcp:send(Sock, Data),
    gen_server:cast(State#state.roompid, {broadcast, Data}),
    {noreply, State};
handle_info({tcp_closed, _}, State) ->
    {stop, "Some Player Lost Connection closed", State};
handle_info({tcp_error, _, _Reason}, State) ->
    {stop, "Some Player Lost Connection error", State};
handle_info(timeout, State) ->
    {stop, "Some Player Lost Connection timeout", State}.
    
terminate(_Reason, State) ->
    gen_tcp:close(State#state.sock),
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

									     
