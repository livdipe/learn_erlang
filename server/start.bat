echo f | copy /y src\muserver.app ebin\muserver.app

FOR %%f in (src\*.erl) DO erlc -W -o ebin "%%f"

erl -pa ebin -eval "application:start(muserver)."