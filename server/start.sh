#!/bin/sh

cp src/muserver.app ebin/muserver.app

erlc -o ebin src/*.erl 

erl -pa ebin -eval "application:start(muserver)."
