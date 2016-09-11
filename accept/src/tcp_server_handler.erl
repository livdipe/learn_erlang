-module(tcp_server_handler).

-behaviour(gen_server).

-export([start_link/1]).

-export([init/1,
        handle_call/3,
        handle_cast/2,
        handle_info/2,
        terminate/2,
        code_change/3]).

-record(state, {lsock, socket, addr}).

start_link(LSock) ->
    gen_server:start_link(?MODULE, [LSock], []).

init([Socket]) ->
    inet:setopts(Socket, [{active, once}, {packet, 2}, binary]),
    {ok, #state{lsock = Socket}, 0}.

handle_call(Msg, _From, State) ->
    {reply, {ok, Msg}, State}.

handle_cast(stop, State) ->
    {stop, normal, State}.

handle_info({tcp, Socket, Data}, State) ->
    inet:setopts(Socket, [{active, once}]),
    io:format("~p got message ~p~n", [self(), Data]),
    ok = gen_tcp:send(Socket, <<"Echo back : ", Data/binary>>),
    {noreply, State};
handle_info({tcp_closed, _Socket}, #state{addr=Addr} = State) ->
    error_logger:info_msg("~p Client ~p disconnected.~n", [self(), Addr]),
    {stop, normal, State};
handle_info(timeout, #state{lsock = LSock} = State) ->
    {ok, ClientSocket} = gen_tcp:accept(LSock),
    {ok, {IP, Port}} = inet:peername(ClientSocket),
    io:format("connection from ~p:~p~n", [IP, Port]),
    tcp_server_sup:start_child(),
    {noreply, State#state{socket = ClientSocket, addr = IP}};
handle_info(_Info, State) ->
    {noreply, State}.

terminate(_Reason, #state{socket=Socket}) ->
    (catch get_tcp:close(Socket)),
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.



