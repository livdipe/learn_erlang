#!/bin/sh

cp src/tcp_server.app ebin/tcp_server.app

erlc -o ebin src/*.erl 

erl -pa ebin -eval "application:start(tcp_server)."
