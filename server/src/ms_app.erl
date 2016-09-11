-module(ms_app).

-behaviour(application).

-export([start/2, stop/1]).

start(_StartType, _StartArgs) ->
    Opts = [binary, {packet, 2}, {reuseaddr, true}, {keepalive, true}, {backlog, 30},
            {active, false}],
    ListenPort = 8765,
    {ok, LSock} = gen_tcp:listen(ListenPort, Opts),
    case ms_sup:start_link(LSock) of
        {ok, Pid} ->
            ms_accept_sup:start_child(),
            {ok, Pid};
         Other ->
            {error, Other}
    end.

stop(_State) ->
    ok.
