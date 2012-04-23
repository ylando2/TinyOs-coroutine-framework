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
  uses interface ProtocolI<nMsg> as P;
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

  double heat;
  double heatSum=0;
  double avgHeat;
  //paret=-1 if it was not found
  //and 0 for the root of the tree
  #define ROOT 0
  int8_t parent=-1;
//a set of less then 20 neighbors id
  uint8_t nSet[20];
//number of neighbors
  uint8_t nSize=0;
//count the number of sons
  uint8_t sonNum=0;
//a message to send
  nMsg Pmsg;
//get heat message only one time
  bool first_time_heat_msg=TRUE;

enum {
OFF=0,
RED=1,
GREEN=2,
BLUE=4,
ALL_ON=7
};

double getHeat()
{
	//array of temperature
	double arr[]={1.,2.,3.,4.,5.,6.,7.,8.,9.,10.};
	//return the temperature of the sensor by the index	
	return arr[getId() -1];
}

inline void putHeat_m(double ht,nMsg *m)
{
	uint8_t *p=(uint8_t *)&ht;
	int i;
	for (i=0;i<sizeof(double);i++)
	{
		m->heat[i]=p[i];	
	}
}

inline double getHeat_m(nMsg *m)
{
	double temp;
	uint8_t *p=(uint8_t *)&temp;
	int i;
	for (i=0;i<sizeof(double);i++)
	{
		p[i]=m->heat[i];	
	}
	return temp;
}


//start the program
  event void Boot.booted()
  {
    PRINT("Boot node id: %d\n",getId());
    //Start radio
    call AMControl.start();
    //init program
    parent=-1;
    //Start corutines
    call Co.start();
  }

//start running the protocol
  void startRunning()
  {
	//the root of the tree
	parent=0;
    	//A message from this protocol
	call Co.notify(1);
  }


//The corutine main function
  event void Co0.run()
  {
static uint8_t mode=0;

switch (mode)
{
//start of the function
case 0:
heat=getHeat();

PRINT("The temperature of node %d is %f\n",getId(),heat);


   if (getId()==1)
   {	
//give the thread a chance to sleep
   call Leds.set(ALL_ON);
   mode=1;
   case 1:
   if (call Co.sleep(2000)) return;
	startRunning();
        call Leds.set(RED);
   }
	//Coroutine block 1
	mode=2;
        case 2:
	//Wait untill msg resived
	if (call Co.wait()) return;
	PRINT("The graph average heat is %f\n",avgHeat);
        call Leds.set(GREEN);
	while (TRUE) { 
	mode=3;
	case 3:
	if (call Co.wait()) return;
	}//end of while(true)
   }//end coroutine
}

//count thread 
  event void Co1.run()
  {
   static uint8_t mode=0;
	switch (mode){
	case 0:
	if (call Co.wait()) return;
	
	if (parent!=ROOT)
	{
	//Send who ack message
	Pmsg.id=getId();
	Pmsg.targetId=parent;
	Pmsg.type=WHOACK;
	call Co.notify(2);//P.send(&Pmsg);
	
	mode=2;
	case 2:
	if (call Co.sleep(1000)) return;
	}
	
	//Send who message
	Pmsg.id=getId();
	Pmsg.type=WHO;
	call Co.notify(2);//P.send(&Pmsg);
	
	mode=3;
	case 3:
	if (call Co.sleep(5000)) return;
	while(nSize>0)
	{
	mode=4;
	case 4:
	if (call Co.wait()) return;
	}
	if (parent!=ROOT)
	{
		//Send son number and heat sum
		Pmsg.id=getId();
		Pmsg.targetId=parent;
		Pmsg.sonNum=sonNum;
		putHeat_m(heat+heatSum,&Pmsg);
		Pmsg.type=SONMSG;
                call Leds.set(BLUE);
		call Co.notify(2);//P.send(&Pmsg);
	}
	else
	{
		//Send the average heat
		Pmsg.id=getId();
		//Average heat
		PRINT("heat+heatSum=%f,sonNUN+1=%d\n",heat+heatSum,sonNum+1);
		putHeat_m(((heat+heatSum)/(sonNum+1)),&Pmsg);
		Pmsg.type=HEAT;
		call Co.notify(2);//P.send(&Pmsg);
		//Dispatch the average heat
		avgHeat=(heat+heatSum)/(sonNum+1);
		call Co.notify(0);
	
	}
	while (TRUE) {
        //no more job to do in this corutine
	mode=5;
	case 5:
	if (call Co.wait()) return;		
	}
	}//end switch
  }

//send every message 3 times
  event void Co2.run()
{
	static int mode=0;
	static int i;
	switch (mode) {	
	case 0:
	while (TRUE) {		
	mode=1;
	case 1:
	if (call Co.wait()) return;	
	//send a message 3 times	
	for (i=0;i<3;i++)
	{
	  case 2:
	  mode=2;
	  if (call Co.sleep(250)) return;
	  call P.send(&Pmsg);
	}
	
	}
	
	}
}
	
//Handle receiving of local msg
  event void P.receive(nMsg* msg)
  {
	if (msg->type==WHO)
	{
		if (parent==-1)
		{
			PRINT("the parent of node %d is: %d\n",getId(),
				msg->id);
                        call Leds.set(RED);
			parent=msg->id;
			call Co.notify(1);
		}
	}

	if (msg->type==WHOACK)
	{
		if (msg->targetId==getId())
		{
			//Check if it is in son list
			bool exist=FALSE;
			int i;
			for (i=0;i<nSize;i++)
			{
				if (nSet[i]==msg->id) 
				{
					exist=TRUE;
					break;
				}
			}
			//If not add it to the list
			if (!exist)
			{
			nSet[nSize]=msg->id;
			nSize++;
			}
		}
	}
	if (msg->type==SONMSG)
	{
		if (msg->targetId==getId())
		{
			//Check if the message is from a son			
			bool exist=FALSE;
			int pos;
			int i;
			for (i=0;i<nSize;i++)
			{
				if (nSet[i]==msg->id) 
				{
					pos=i;
					exist=TRUE;
					break;
				}
			}
			if (exist)
			{
			//Delete son from the list
			for (i=pos;i<nSize;i++)
				nSet[i]=nSet[i+1];
			nSize--;
			sonNum+=1+msg->sonNum;
			heatSum+=getHeat_m(msg);
			call Co.notify(1);
			}
		}
	}

	if (msg->type==HEAT)
	{
		if (first_time_heat_msg)
		{
		   
		//Get the message only from the parent
		if (msg->id==parent)
		{
			first_time_heat_msg=FALSE;
			//Dispatch the average heat
			avgHeat=getHeat_m(msg);
			call Co.notify(0);
			//If it has sons
			if (sonNum>0)
			{
				int i;
				//Send the average heat
				Pmsg.id=getId();
				//Average heat
				//copy heat data
				for (i=0;i<sizeof(double);i++)
					Pmsg.heat[i]=msg->heat[i];
				Pmsg.type=HEAT;
				call Co.notify(2);//P.send(&Pmsg);
			}
		}
		}
	}
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

