-module(die_please2).

-export([go/0]).

-define(SLEEP_TIME, 2000).

go() ->
	timer:sleep(?SLEEP_TIME),
	i_really_want_to_die = right_now.
