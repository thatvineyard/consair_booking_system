-module(server_prototype).
-export([start_send/2, start_recv/1, connect_send/3, connect_recv/2, connect/2, listener/3, talker/3, start_server/1, start_client/3]).


-define(CONNECTIONOPTIONS, [binary, {packet, 4}, {active, false}]).
-define(CONNECTIONOPTIONS_AUX, [binary, {packet, 0}, {active, false}]).


%% HOW TO USE: use start_send or start_recv on "server" with appropriate arguments
%% Use use connect_recv or connect_send respectively on "client" to contact the server.
%% Port: usually 33333
%% Message: a bitstring. can be a normal string, but should be within << >> if something else. Example: <<1,1,1,1,1>>
%% IP: IP of server. If using the same computer write "localhost" (including the quotation marks).






start_server(Port) ->
    %% open port
    {ok, LSock} = gen_tcp:listen(Port, ?CONNECTIONOPTIONS),
    listener_spawner(LSock, 1).

listener_spawner(_, 0) ->
    io:fwrite("Exit message recieved, closing~n");

listener_spawner(LSock, N) ->
    receive
	exit ->
	    listener_spawner(LSock, 0);
	terminated -> 
	    io:fwrite("Connection terminated.~n"),
	    listener_spawner(LSock, N-1)
    after 100 ->
	    %% connect to other device
	    case gen_tcp:accept(LSock, 100) of
		{ok, Sock} ->
		    %% spawn process to handle this connection
		    NewPID = spawn(server_prototype, listener, [Sock, N, self()]),
		    io:fwrite("Number of connections: ~p, new process: ~p~n", [N, NewPID]),
		    listener_spawner(LSock, N+1);
		{error, timeout} ->
		    listener_spawner(LSock, N)
	    end
    end.
    
listener(Sock, ID, ParentPID) ->    
    gen_tcp:send(Sock, <<ID>>),
    io:fwrite("C~p: Awaiting message...~n", [ID]),
    case gen_tcp:recv(Sock, 0, 30000) of
	{error, timeout} -> 
	    io:fwrite("..."),
	    listener(Sock, ID, ParentPID);
	{error, closed} ->
	    io:fwrite("C~p: Connection terminated.~n", [ID]);
	{error, Error} ->
	    io:fwrite("C~p: Error: ~p~n", [ID, {error, Error}]),
	    {error, Error};
	{ok, <<"exit">>} ->
	    ParentPID ! exit,
	    io:fwrite("C~p: Exit message received, sending to parent~n", [ID]);
	{ok, Package} ->
	    io:fwrite("C~p: Message recieved: ~p~n", [ID, Package]),
	    gen_tcp:send(Sock, translate_package(Package)),
	    listener(Sock, ID, ParentPID)
    end.

translate_package(Package) ->
    case Package of
	<<"Hello">> ->
	    "Hello";
	<<"Foo">> ->
	    "Bar";
	<<"Ipsum">> ->
	    "Lorem";	
	<<1, 2, 3>> ->
	    "One, Two, Three";
	_ ->
	    "I didn't understand that"
    end.

start_client(IP, Port, Message) ->
    talker_spawner(IP, Port, Message).

%% Recursive spawner of processes to go through the message list. 

talker_spawner(_, _, []) ->
    io:fwrite("Final message proccess spawned.~n");

talker_spawner(IP, Port, [Message | MessageTail]) ->
    NewPID = spawn(server_prototype, talker, [IP, Port, Message]),
    io:fwrite("Spawned ~p with message ~p~n", [NewPID, Message]),
    talker_spawner(IP, Port, MessageTail).

talker(IP, Port, Message) ->
    %% Connect to IP and Port and receive ID
    Sock = connect(IP, Port),
    {ok, <<ID>>} = gen_tcp:recv(Sock, 0),
    io:fwrite("C~p: Connection established, ID ~p allocated~n", [ID, ID]),

    %% Random sleep time
    random:seed(erlang:now()),
    timer:sleep(random:uniform(10000)),
    
    %% Send message
    gen_tcp:send(Sock, Message),
    io:fwrite("C~p: ~p sent!~n", [ID, Message]),
    
    %% Wait 3 seconds to receive a message
    case gen_tcp:recv(Sock, 0, 3000) of
	{error, timeout} ->
	    io:fwrite("C~p: No response~n", [ID]);
	{error, closed} ->
	    io:fwrite("C~p: Connection terminated.~n", [ID]);
	{error, Error} ->
	    io:fwrite("C~p: Error: ~p~n", [ID, {error, Error}]);
	{ok, Package} ->
	    io:fwrite("C~p: Message received: ~p~n", [ID, Package])
    end.



%% MANUAL FUNCTIONS %%

start_send(Port, Message) ->
    Sock = start(Port),
    timer:sleep(1000),
    gen_tcp:send(Sock, Message),
    gen_tcp:close(Sock).

start_recv(Port) ->
    Sock = start(Port),
    {ok, Packet} = gen_tcp:recv(Sock, 0),
    gen_tcp:close(Sock),
    Packet.

start(Port) ->
    {ok, LSock} = gen_tcp:listen(Port, ?CONNECTIONOPTIONS),
    {ok, Sock} = gen_tcp:accept(LSock),
    Sock.

connect_send(IP, Port, Message) ->
    Sock = connect(IP, Port),
    gen_tcp:send(Sock, Message).

connect_recv(IP, Port) ->
    Sock = connect(IP, Port),  
    {ok, Package} = gen_tcp:recv(Sock, 0),
    Package.

connect(IP, Port) ->
    {ok, Sock} = gen_tcp:connect(IP, Port, ?CONNECTIONOPTIONS),
    Sock.
