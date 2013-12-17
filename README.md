SignalRF
========

*A Flex/AS3 implementation of the SignalR Client*

Currently supports version 2.0.x of SignalR.

Explanation
-----------
So, this is the first pass at creating a Flex/AS3 SWC SignalR Client. It works very similarly to the .NET client.

It only supports the WebSocket transport at this point. Why? Because that is what I needed and I dont have time to code any other transport type at the moment. 

Basically I went through the code for both the .NET and Javascript clients and tried to copy the flows for message send and receive as well as the lifetime connection events.
It was a bit difficult at times because neither codebase translated well to AS3. I ended up copying the interfaces for the .NET client and then tried to fillout the implementations by mostly copying the .NET code but at times using the Javascript code becuase it was a bit closer to AS3 symantically.

*I apologize for there not being any test project(s), but when I started this I didnt think it through so my backend signalR stuff isnt appropriate for posting as a generic testing/demo piece*

A number of other projects have been rolled into this one, namely:

-AS3WebSocket, which has been modified slightly to handle the bearer and basic auth headers. Original code can be found here: [AS3WebSocket](https://github.com/Worlize/AS3WebSocket)

-AS3-Async-Tasks, which has been modified slightly as well. This library essentially emulates the C# Task framework in AS3. Original code can be found here: [AS3-Async-Tasks](https://github.com/Strilanc/AS3-Async-Tasks)

-[as3crypto](http://code.google.com/p/as3crypto/), this was included as part of the AS3Websocket code

-The task queue parts of the developmentarc-core library have been used to handle message queuing [developmentarc-core](https://code.google.com/p/developmentarc-core/)

License
-------
This library is released under the Apache License, Version 2.0.

Download
--------
The release version of the SignalRF.swc can be found in release-bin.

Usage
--------
*Caveat*
Objects passed to signalR must extend from the SignalRObject class. This is used to facilitate type generics on AS3 since there is no JSON decode to <T> in AS3. My solution was to pass the T into the method as a paramaeter and then the base code uses this to parse the JSON received and create that "dynamic" class to be returned to the user code.

Example Code
--------
    
	//create new connection
	var signalRF:HubConnection = new HubConnection();
	
	//listen for state changes
	signalRF.addEventListener(SignalREvent.STATE_CHANGED, function(e:SignalRStateChangedEvent):void{
    		trace(e.newState.toString());
    	});
	
	//*this varies from the normal clients where this is passed int he constructor
	//initialize the connection, change the URL to your signalR endpoint
	signalRF.init("http://my.testlab.dev/signalr",null,true);
	
	//if your endpoint requires authentication you can do this in one of two ways
	// set a bearer token, useful for the new ASP.Net identity OWIN OAuth stuff
	//signalRF.headers["Authorization"] = "Bearer " + token;
		//OR
	// set credentials that will activate the Basic Auth token header
	//signalRF.credentials = new Credentials("test","password");
	
	//create a new hub proxy
	var gamehub:IHubPorxy = signalRF.createHubProxy("gameHub");
	
	//Start the connection
	// this uses the async task framework to allow chained notation such as .await() .continueWith()
	// see the async documentation for more info [AS3-Async-Tasks](https://github.com/Strilanc/AS3-Async-Tasks)
	signalRF.start().await(function():void{
		if(signalRF.state == ConnectionState.CONNECTED){
			trace("start complete");
		}
	});
	
	//Once the connection is open you can call methods on the server by using
	// you can see the faked generics here with invoke$T where the second argument
	// is the class "Game" which extends SignalRObject.
	gamehub.invoke$T("findGame",Game,false, game).continueWith(function(result:*):void{
		game = result as Game;
		// do something
	});
	
	//To allow the server to call methods on the client use
	gamehub.on("updateGame",Game, function(model:Game):void{
		game = model;
		// do seomthing
	});
	
	//and to stop the server from calling client methods
	gamehub.off("updateGame");
