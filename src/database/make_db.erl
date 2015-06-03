%%---------------------------------------------------%%
%% THIS FILE IS FOR MAKEING THE DATABASE STRUCTURE   %%
%%---------------------------------------------------%%

-module(make_db).
-export([init/1]).
-include("consair_database.hrl").
-include("amnesia.hrl").

%%---------------------------------------------------%%
%% TO BE ABLE TO MAKE THE DB WITH YOUR OWN PASSWORD  %%
%%---------------------------------------------------%%


init(PASSWORD)->
    amnesia:db_tool(consair_database, [{make_hdr, "."},make_db, {dba_user, "root"}, {dba_password, PASSWORD}]).
