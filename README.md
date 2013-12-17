SignalRF
========

*A Flex/AS3 implmentation of the SignalR Client*

Explanation
-----------
So, this is the first pass at creating a Flex/AS3 SWC SignalR Client. It works very similarly to the .NET client.

It only supports the WebSocket transport at this point. Why? Because that is what I needed and I dont have time to code any other transport type at the moment. 

Basically I went through the code for both the .NET and Javascript clients and tried to copy the flows for message send and receive as well as the lifetime connection events.
It was a bit difficult at times because neither codebase translated well to AS3. I ended up copying the interfaces for the .NET client and then trying to fillout the implementations of them by mostly copying the .NET code but at times using the Javascript code becuase it is a bit closer to AS.

A number of other projects have been rolled into this one, namely:

-AS3WebSocket, which has been modified slightly to handle the bearer and basic auth headers. Original code can be found here: [AS3WebSocket](https://github.com/Worlize/AS3WebSocket)

-AS3-Async-Tasks, which has been modified slightly as well. This library essentially emulates the C# Task framework in AS3. Original code can be found here: [AS3-Async-Tasks](https://github.com/Strilanc/AS3-Async-Tasks)

-[as3crypto on Google Code](http://code.google.com/p/as3crypto/), this was included as part of the AS3Websocket code
