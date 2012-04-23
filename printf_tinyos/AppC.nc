/*****************************************************************************************************
*************                   Created By: Yuval Lando                    ***************************
*****************************************************************************************************/

#include "Timer.h"
#include "macro.h"
#include "AppC.h"
#include "printf.h"


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
//Printf interfaces
  uses interface SplitControl as PrintfControl;
  uses interface PrintfFlush;
}
implementation
{

//inline functions macro
inline uint8_t getId() {return TOS_NODE_ID;}
inline uint32_t getTime() {return call Co.getTime();} 
//shorter printing function macro
//#define PRINT(...) dbg("debug",__VA_ARGS__)
#define PRINT(...) printf(__VA_ARGS__);\
call PrintfFlush.flush();


//Hold the message
  AppCMsg sendMsg,receiveMsg;


event void PrintfFlush.flushDone(error_t error) {
  if (error!=SUCCESS) call PrintfControl.stop();
}


event void PrintfControl.startDone(error_t err) {
//don't do nothing
//after printf start
}

event void PrintfControl.stopDone(error_t error) {
  //don't do nothing
  //will not print any more
}

//start the program
  event void Boot.booted()
  {
    //Initialize printf
    call PrintfControl.start();
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
        // Give the program time to boot
	if (call Co.sleep(1000)) return;
	PRINT("This is mote id:%d\n",getId());
	while (TRUE){
	case 1:
	mode=1;
	if (call Co.wait()) return;	
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

