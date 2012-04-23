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
  uses interface ProtocolI<AppCMsg> as P;
//corutine commands
 uses interface CoCommandsI as Co;
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
  AppCMsg sendMsg,receiveMsg;


//start the program
  event void Boot.booted()
  {
    PRINT("Boot node id: %d\n",getId());
    //Start radio
    call AMControl.start();
    //Start corutines
    call Co.start();
  }


//The corutine main function
  event void Co0.run()
  {
   static int8_t mode=0;
   //start of corutine
   switch (mode)
   {	
	case 0:
	if (call Co.sleep(200)) return;
	//node 1 send message to other nodes	
	if (getId()==1)
	{
		sendMsg.counter=7;
		PRINT("node 1 sending msg at time %d\n",getTime());
		call P.send(&sendMsg);		
		//send_local(&sendMsg);	
	}

	while (TRUE) {
	mode=1;	
	case 1:
	if (call Co.receive_block(LOCAL_MSG)) return;
	PRINT("Node %d get the msg at time %d\n",getId(),getTime());	
	}

   }  
  }

//Handle receiving of local msg
  event void P.receive(AppCMsg* m)
  {
    receiveMsg=*m;
    call Co.dispatch(LOCAL_MSG);
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

