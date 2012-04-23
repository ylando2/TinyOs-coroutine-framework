/*****************************************************************************************************
*************                   Created By: Yuval Lando                    ***************************
*****************************************************************************************************/

#include "Timer.h"
#include "macro.h"
#include "AppC.h"


module AppC
{
//Leds commands
  uses interface Leds;
//Boot command
  uses interface Boot;
//Start the radio
  uses interface SplitControl as AMControl;
//Protocol for sending and receiving messages
  uses interface ProtocolI<Who> as WhoP;
  uses interface ProtocolI<WhoAck> as WhoAckP;
  uses interface ProtocolI<RandomMsg> as RandomP;
//corutine commands
 uses interface CoCommandsI as Co;
//random interfaces
 uses interface Random;
 uses interface ParameterInit<uint16_t> as RandomInit; 
//Auto define corutine interface use
  USE_INTERFACE  

}
implementation
{

//inline functions macro
inline uint8_t getId() {return TOS_NODE_ID;}
inline uint32_t getTime() {return call Co.getTime();} 
//shorter printing function macro
#define PRINT(...) dbg("debug",__VA_ARGS__)


//Hold the message
  UMsg sendMsg,receiveMsg;
//Hold the neighbor id's
#define MAX_NLIST_SIZE 10
uint8_t nList[MAX_NLIST_SIZE];
uint8_t nSize=0;

//variables for acknowledge
uint8_t ackTargetId; //target id for acknowledge

//variables for random walk
//maximum steps for the random walk
#define MAX_INDEX 10
uint8_t msgIndex; //index for last receive message in random walk
bool busy=FALSE; //busy sending random walk messages

enum {
OFF=0,
RED=1,
GREEN=2,
BLUE=4,
ALL_ON=7
};

inline void cleanList()
{
	nSize=0;
}

inline bool elemExist(uint8_t elem)
{
  uint8_t i;
  for (i=0;i<nSize;i++)
	if (nList[i]==elem) return TRUE;
  return FALSE;
} 

inline void addElem(uint8_t elem)
{
	if (nSize==MAX_NLIST_SIZE) return;
	if (elemExist(elem)) return;
	nList[nSize]=elem;
	nSize++;
}

//start the program
  event void Boot.booted()
  {
    PRINT("Boot node id: %d\n",getId());
    //Start radio
    call AMControl.start();
    //Start corutines
    call Co.start();
  }

//Handle receiving of Who msg
  event void WhoP.receive(Who * msg)
  {
    PRINT("Resiving who msg\n");
    call Leds.set(BLUE);
    call RandomInit.init(getTime());
    ackTargetId= msg->id;
    call Co.notify(1);//notify "neighborT" corutine 
  }

//Handle receiving of WhoAck msg
  event void WhoAckP.receive(WhoAck *msg)
  {
    if (msg->targetId!=getId()) return;
    PRINT("Resiving whoAck msg\n");
    //init random (at a random time)
    call RandomInit.init(getTime());
    addElem(msg->id); 
  }

//Handle receiving of RandomMsg msg
  event void RandomP.receive(RandomMsg * msg)
  {
    if (busy) return;
    if (msg->targetId != getId()) return;
    if (msg->index >=MAX_INDEX) {
    call Leds.set(GREEN);
    PRINT("End the random walk\n");
    return;
    }
    PRINT("Get a random message with a index of %d\n",msg->index);
    busy=TRUE;
    call Leds.set(RED);
    msgIndex= msg->index;
    call Co.notify(2);// Notify "randomT" corutine 
  }

//Ask who is my neighbors
inline void sendWhoMsg() {
   sendMsg.who.id=getId();
   call WhoP.send(&sendMsg.who);
}

//answer the question who is my neighbor
inline void sendWhoAckMsg(uint8_t targetId)
{
  call Leds.set(OFF);
  sendMsg.whoAck.id=getId();
  sendMsg.whoAck.targetId=targetId;
  call WhoAckP.send(&sendMsg.whoAck);
}

//Start the random walk
inline void sendRandomMsg()
{
    if (busy) return;
    //Can send only one random walk message at a time
    busy=TRUE;
    call Leds.set(RED);
    msgIndex=0;
    call Co.notify(2);// Notify "randomT" corutine    
}
 
//The corutine main function
//#mainT
event void Co0.run()
{
   static int8_t mode=0;
   //start corutine
   switch (mode) {
   case 0:
   if (getId()==1) 
      {
      //Wait 2 sec for the sensor to initialize before starting the random walk.
      call Leds.set(ALL_ON);
      mode=1;
      case 1:
      if (call Co.sleep(2000)) return;
      PRINT("Start the random walk\n");
      sendRandomMsg();
      }
   while (TRUE) 
      {
      mode=2;
      case 2:
      if (call Co.wait()) return;
      }
   } //end corutine
}

// "neighborT" corutine send acknowledge
//#neighborT
event void Co1.run()
{ 
     static uint8_t mode=0;
     static uint16_t sleepTime;
     switch (mode) 
     {
     case 0:
     while (TRUE)
       {
       uint16_t randInt;
       mode=1;
       case 1:
       if (call Co.wait()) return;
       randInt=call Random.rand16() % ((WAIT_TIME-RADIO_WAIT)/INTERVAL);
       sleepTime=randInt*INTERVAL+RADIO_WAIT;
       mode=2;
       case 2:
       if (call Co.sleep(sleepTime)) return;
       //answer the question who are my neighbors
       sendWhoAckMsg(ackTargetId);
       PRINT("send acknowledge\n");
       }
     }
}

// "randomT" corutine send the random walk messages
//#randomT
event void Co2.run()
{
   static uint8_t mode=0;
   static uint8_t tryNum;
   switch (mode)
   {
   case 0:
   while (TRUE)
      {
      mode=1;
      case 1:
      if (call Co.wait()) return;
      PRINT("has the message \n");
      mode=2;
      case 2:
      //Wait for the sender of the random message to stop
      //sending messages 
      if (call Co.sleep(750)) return; 
      tryNum=0;
      while (nSize==0 && tryNum<3) 
        {
        tryNum++;
        sendWhoMsg();
        mode=3;
        case 3:
        if (call Co.sleep(WAIT_TIME)) return;
        if (nSize>0) 
           {
              uint16_t randInt=call Random.rand16() % nSize;
              uint8_t randomTarget=nList[randInt];
              sendMsg.randomMsg.targetId=randomTarget;
              msgIndex++;
              sendMsg.randomMsg.index=msgIndex;
              call RandomP.send(&sendMsg.randomMsg);
              mode=4;
              case 4:
              if (call Co.sleep(250)) return;
              call RandomP.send(&sendMsg.randomMsg);
              mode=5;
              case 5:
              if (call Co.sleep(250)) return;
              call RandomP.send(&sendMsg.randomMsg);
           }// if (nSize>0) 
        }// while (nSize==0)
      cleanList();
      busy=FALSE;
      call Leds.set(OFF);
      }//while (TRUE)
   }//end corutine
}

// Start the radio events
  event void AMControl.startDone(error_t err) {
    if (err == SUCCESS) {
	//if is succed in starting the radio don't do nothing 
    }
    else {
	//if failed try again
      call AMControl.start();
    }
  }

  event void AMControl.stopDone(error_t err) {
}


}

