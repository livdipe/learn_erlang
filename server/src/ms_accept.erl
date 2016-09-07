-module(ms_accept).

-behaviour(gen_server).

-export([start_link/0]).

-export([init/1,
	 handle_call/3,
	 handle_cast/2,
	 handle_info/2,
	 terminate/2,
	 code_change/3]).

start_link() ->
    Port = 8765,
    gen_server:start_link({local, ?MODULE}, ?MODULE, [Port], []).

init([Port]) ->
    {ok, Sock} = gen_tcp:listen(Port, [binary, {reuseaddr, true}, {active, once},
				       {nodelay, true}, {ip, {0, 0, 0, 0}}, inet, {packet, 2}]),
    gen_server:cast(self(), accept),
    {ok, Sock}.
				       
handle_call(_Request, _From, State) ->				     
    Reply = ok,
    {reply, Reply, State}.

handle_cast(accept, Sock) ->
    {ok, Client} = gen_tcp:accept(Sock),
    io:format("A Client Connected: ~p~n", [Client]),
    {ok, Pid} = ms_player_sup:create_player(Client),
    io:format("Pid:~p~n", [Pid]),
    gen_tcp:controlling_process(Client, Pid),
    gen_server:cast(self(), accept),
    {noreply, Sock}.

handle_info(_Info, State) ->
    {noreply, State}.

terminate(_Reason, Sock) ->
    gen_tcp:close(Sock),
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.
