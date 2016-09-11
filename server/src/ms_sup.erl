-module(ms_sup).

-behaviour(supervisor).

-export([start_link/1]).

-export([init/1]).

start_link(LSock) ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, [LSock]).

init([LSock]) ->
    AcceptSupervisor = {
      ms_accept_sup, {ms_accept_sup, start_link, [LSock]},
      permanent, infinity, supervisor, [ms_accept_super]
     },

     PlayerSupervisor = {
     	ms_player_sup, {ms_player_sup, start_link, []},
     	permanent, infinity, supervisor, [ms_player_sup]
     },

     RoomSupervisor = {
        ms_room_sup, {ms_room_sup, start_link, []},
        permanent, infinity, supervisor, [ms_room_sup]
     },
    
     RoomManager = {
       ms_roommanager, {ms_roommanager, start_link, []},
       temporary, 2000, worker, [ms_roommanager]
     },

    Restart = {one_for_one, 5, 10},
    {ok, {Restart, [AcceptSupervisor, PlayerSupervisor, RoomSupervisor, RoomManager]}}.
    
