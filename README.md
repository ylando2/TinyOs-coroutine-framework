TinyOs-coroutine-framework
=========================

Programmer: Yuval Lando

About
---------------------
A few years ago, I wrote programs for real sensors.
Sensors are very small (the size of a matchbox) 
computers with a usb connection and radio device.
I try to write in sentilla but it took too much memory for real world use. 
I try to write on tiny-os but nesc and callback style can became ugly fast.
Then I discovered a way to emulate the threads of sentilla on tiny-os.
It is done by using coroutine build on a duff device.
I do not have those devices around me anymore.
If you want me to maintain/expand the framework you can hire me as
a programmer (or consultant) my email is:
ylando2@gmail.com

Files this framework
---------------------------
If you want to build your own program the best approach is to expand the program 
found in local_tinyos folder.

There are six folders:   
* local_tinyos - one sensor send it a message to the other sensors, other sensors receive the message.
* random_walk_tinyos - implementation of random walk.
* tiny-avarage_t - It suppose to calculate the average temperature but I did not install the sensors yet
so it gets the temperature from the function getHeat.
* printf_tinyos - It print the moteid on the computer connected to the mote (mote is a sensor node).
* gateWay_tinyos - get a number n and return a n+7 the result is printed on the console.
* getting a Double GateWay_tinyos - like gateWay_tinyos but sending a floating number
(a double in mote is at the size of a float in java).

Remembering the tiny-os batch command is hard so I add shall script files.
The shell script files are:
* buildprog - compile the program.
* buildsim -compile a tossim simulator.
* runsim - run the simulator.
* makeprog [moteid] [path] - copy the program into the sensor give it the id [moteid], path is the usb path. This path can be found by
using the command motelist.
* createjavamsg - create java file that represent the message found on AppC.h that are on the list in msgList.txt
* buildjni [cprog] [javaprog] - connect java program to c program.

This program use external files that are:
* test.py - Running the tossim simulator.
* topo.txt - holding the arrangement of the nodes in the simulator; This file is in the following format:
node1_id node2_id noise node3_id node4_id noise ...
* meyer-heavy.txt - a noise list for the simulator.
* runmig.perl - using mig to generate java files that represent the messages. It is used by createjavamsg.

The program itself:
* AppC.h - message declaration.
* AppC.nc - the main module contain the program itself.
* AppConfC - contain the structure of the program in the following way:   
declare component by `components name1,name2,...;` and connect component by
`[component user name].[interface name] ->[component provider name].[interface name];`
* conf.h - contain three definitions: APP_NAME the name of the main module,
INTERFACE_NAME the prefix of the coroutine interface names and
CORUTINE_NUM the number of coroutines.
For example: a program with INTERFACE_NAME co and CORUTINE_NUM 3
will have there function co0.run,co1.run and co2.run.
* macro.h - helper header to automate the wiring of the coroutine.
* CorutineM - The main implementation of the coroutine.
* localProtocolC - make the building of a message sending and receiving protocol easy by using: `new LocalProtocolC(msg_type,msg_id) as name;`
where msg_type is the type of the message and msg_id is the identify number of the message.
* TinyConsole.java - Java client.

How program the framework:
-----------------------------

The main program looks something like this:
```c
event void Co0.run()
{
  static int8_t mode=0;
  switch (mode)
  {	
    case 0:
    
    while(true) 
    {
      //In c switch can go into while scope
      mode=1;
      case 1:
      //If stopping exit the function other wise continue
      if (stop_func()) return;
    }
  }
}
```
Make sure that all variables of run are global or static.

Sending message is done by: 
`call protoName.send(&message);`

Receiving message is done by:
```c
mode=[number];
case [number]:
if (call Co.receive_block(msgId)) return;
```

If you want to have a timeout you can do:
```c
mode=[number];
case [number]:
if (call Co.receive_block_time(msgId,time)) return;
```

It also support sleep by:
```c
mode=[number];
case [number]:
if (call Co.sleep(time)) return;
```
"time" is time in milliseconds.

It support waiting for notify by:
```c
mode=[number];
case [number]:
if (call Co.wait()) return;
```
And wait with timeout by:
```c
mode=[number];
case [number]:
if (call Co.wait_time(time)) return;
```
To notify a coroutine we write:
```c
call Co.notify(coroutine_number);
```
The protocol message handling is done by:
```c
event void ProtocolName.receive(messageType* m)
{
  receiveMsg=*m;
  call Co.dispatch(MESSAGE_ID);
}
```
Finally we wire the protocol by:
Adding:
```c
components new Local_protocolC(messageType,messageId) as ProtocolName;
AppC.P1 -> ProtocolName.P;
```
to AppConfC.nc and adding:
```c
uses interface ProtocolI<AppCMsg> as P1;
```
to appC.nc

appC.nc has two useful inline functions:
getId - return the mote id.
getTime - return current time in milliseconds.

Testing the program
-----------------------
We can use tossim simulator or use my own sensor simulator found in
[sensor-networks-simulator](https://github.com/ylando2/Sensor-networks-simulator) repository.

Miscellaneous technical issues:
---------------------------------
You cannot send a message with odd number of bytes.
If there is a bug try adding a `char dummy` to the message struct.
The type size in nesc and java are different so
double in nesc is float in java.
 
License
-------
TinyOs-coroutine-framework is released under the MIT license.
