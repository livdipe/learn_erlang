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
    inet:setopts(LSock, [{active, once}, {packet, 2}, binary]),
    {ok, #state{lsock = LSock}, 0}.
				       
handle_call(Msg, _From, State) ->				     
    {reply, {ok, Msg}, State}.

handle_cast(stop, State) ->
    {stop, normal, State}.

handle_info(timeout, #state{lsock = LSock} = State) ->
    {ok, ClientSocket} = gen_tcp:accept(LSock),
    {ok, {IP, Port}} = inet:peername(ClientSocket),
    io:format("connection from ~p:~p~n", [IP, Port]),
    ms_accept_sup:start_child(),
    ms_roommanager:join(ClientSocket),
    {stop, normal, State};
handle_info(_Info, State) ->
    {noreply, State}.

terminate(_Reason, _State) ->
    io:format("ms_accept teminate~n"),
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.
