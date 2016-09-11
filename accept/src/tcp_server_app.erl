-module(tcp_server_app).

-behaviour(application).

-export([start/2, stop/1]).

-define(DEF_PORT, 8766).

start(_Type, _Args) ->
    Opts = [binary, {packet, 2}, {reuseaddr, true}, {keepalive, true}, {backlog, 30},
            {active, false}],
    ListenPort = get_app_env(listen_port, ?DEF_PORT),
    {ok, LSock} = gen_tcp:listen(ListenPort, Opts),
    case tcp_server_sup:start_link(LSock) of
        {ok, Pid} ->
            tcp_server_sup:start_child(),
            {ok, Pid};
        Other ->
            {error, Other}
    end.

stop(_S) ->
    ok.

get_app_env(Opt, Default) ->
    case application:get_env(application:get_application(), Opt) of
        {ok, Val} ->
            Val;
        _ ->
            case init:get_argument(Opt) of
                [[Val | _]] -> Val;
                error -> Default
            end
    end.

