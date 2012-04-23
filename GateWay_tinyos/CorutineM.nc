/*****************************************************************************************************
*************                   Created By: Yuval Lando                    ***************************
*****************************************************************************************************/

#include "conf.h"

module CorutineM
{
  provides interface CorutineI[uint8_t];
  provides interface CoCommandsI as Co;
  uses interface Timer<TMilli> as Timer;
}
implementation
{
  
//Hold the index to the running corutine
//change it only in tasks
uint8_t coIndex;
//waiting to timer to hit
bool wait_to_timer=TRUE;
//Msg resive type
int8_t msgReceived;
//hold time for the next timer to wake
int32_t wakeTime;

//Struct that hold corutine data
typedef struct {
int32_t blockT;
bool waitMode;
bool hasNotify;
} CoStruct;

//Array of corutines data
CoStruct coArr[CORUTINE_NUM];

  default event void CorutineI.run[uint8_t num]()
  {
    dbg("debug","error corutine %d does not exist\n",num); 
    return;
  }

//Build one task for every corutine
BUILDTASKS

inline void wake(uint32_t dt)
{
	if (wakeTime<0 || wakeTime>dt)
		wakeTime=dt;
}


task void setNextRun()
{
	if (wakeTime!=-1)
	{
		call Timer.startOneShot(wakeTime);
	}
	wait_to_timer=TRUE;
}

command bool Co.sleep(uint32_t dt)
{
	uint32_t now;
	now=call Timer.getNow();
	if (coArr[coIndex].blockT==-1)
	{
		coArr[coIndex].blockT=now;
	}
	if (now-coArr[coIndex].blockT<dt)
	{
		wake(dt);
		return TRUE;
	}
	else
	{
		coArr[coIndex].blockT=-1;
		return FALSE;//exit block becouse 
		//it has run tic times on the block
	}
}

command bool Co.receive_block(uint8_t msgId)
{
	if (msgReceived!=msgId) return TRUE;
	//replace the call for getMsg	
	msgReceived=-1;
	return FALSE;
}

command bool Co.receive_block_time(uint8_t msgId,uint32_t dt)
{
	uint32_t now;
	//return true if msg do not exist
	bool msgNotExist;
	
	now=call Timer.getNow();
	if (msgReceived==-1) msgNotExist=TRUE;
	else
	if (msgReceived!=msgId) msgNotExist=TRUE;
	else
		msgNotExist=FALSE;

	if (coArr[coIndex].blockT==-1)
	{
		coArr[coIndex].blockT=now;
		
	}
	if (now-coArr[coIndex].blockT<dt && msgNotExist)
	{
		wake(dt);
		return TRUE;
	}
	else
	{
		coArr[coIndex].blockT=-1;
		return FALSE;//exit block becouse 
		//it has run tic times on the block
	}
}

command void Co.dispatch(uint8_t msgId)
{
	msgReceived=msgId;
	//Run the corutine again to handle the message
	if (wait_to_timer)
	{
	   //Call timer
           call Timer.startOneShot(0); 	
	}
	else
	{
	   //Wait for the task to finish before starting new tasks
	   wake(0);
	}	
}

command bool Co.wait()
{
	//start waiting
	if (coArr[coIndex].waitMode==FALSE)
	{
		//notify before wait
		coArr[coIndex].hasNotify=FALSE;
		coArr[coIndex].waitMode=TRUE;
		//keep waiting
		return TRUE;
	}
	//notify while waiting
	if (coArr[coIndex].hasNotify) {
		coArr[coIndex].hasNotify=FALSE;
		coArr[coIndex].waitMode=FALSE;
		//stop waiting
		return FALSE;
	}
	//waiting without notify
	//continue waiting
	return TRUE;
}

command bool Co.wait_time(uint32_t dt)
{
	//dealing with time
	uint32_t now;
	now=call Timer.getNow();
	if (coArr[coIndex].blockT==-1)
	{
		coArr[coIndex].blockT=now;
	}
	//If wait time passed
	if (now-coArr[coIndex].blockT>=dt)
	{
		coArr[coIndex].blockT=-1;
		coArr[coIndex].hasNotify=FALSE;
		coArr[coIndex].waitMode=FALSE;
		//stop waiting
		return FALSE;
	}
	
	//dealing with has notify
	//start waiting
	if (coArr[coIndex].waitMode==FALSE)
	{
		//notify before wait
		coArr[coIndex].hasNotify=FALSE;
		coArr[coIndex].waitMode=TRUE;
		//keep waiting
		wake(dt);
		return TRUE;
	}
	//notify while waiting
	if (coArr[coIndex].hasNotify) {
		coArr[coIndex].hasNotify=FALSE;
		coArr[coIndex].waitMode=FALSE;
		coArr[coIndex].blockT=-1;
		//stop waiting
		return FALSE;
	}
	//waiting without notify
	//and time has not passed
	//continue waiting
	wake(dt);
	return TRUE;
}

command void Co.notify(uint8_t coNum)
{
	//Prevent recursive calls
	if (!coArr[coNum].waitMode) return;
	coArr[coNum].hasNotify=TRUE;
	//Run corutines again to notify one of them	
	if (wait_to_timer)
	{
	   //Call timer
           call Timer.startOneShot(0); 	
	}
	else
	{
	   //Wait for the task to finish before starting new tasks
	   wake(0);
	}	
}

event void Timer.fired()
  {
	wait_to_timer=FALSE;
	wakeTime=-1;
	RUN_ALL_TASKS
	post setNextRun();
  }
  

command void Co.start()
{
//Init corutine
	int i;
	msgReceived=-1;
	wakeTime=-1;
	for (i=0;i<CORUTINE_NUM;i++)
	{
		coArr[i].blockT=-1;
		coArr[i].waitMode=FALSE;
		coArr[i].hasNotify=FALSE;
	}
//Start running
	call Timer.startOneShot(0);
}

command uint32_t Co.getTime()
	{
		return call Timer.getNow();
	}
}

