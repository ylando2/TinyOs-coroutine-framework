/*****************************************************************************************************
*************                   Created By: Yuval Lando                    ***************************
*****************************************************************************************************/

#include "macro.h"
#include "AppC.h"

configuration AppConfC
{
}
implementation
{
  //Program component
  components MainC, AppC, LedsC;
  //Timer
  components new TimerMilliC() as Timer;
  //Corutine manager
  components CorutineM;
  //Component that start the radio
  components ActiveMessageC;
  //Protocols (get msg type and msg id)
  components new Local_protocolC(Who,WHO_MSG) as WhoP;
  components new Local_protocolC(WhoAck,WHO_ACK_MSG) as WhoAckP;
  components new Local_protocolC(RandomMsg,RANDOM_MSG) as RandomP;
  components RandomC;
  //Auto wire macro for corutine 
  WIRE_INTERFACE  

  //Wire timer  
  CorutineM.Timer -> Timer;
  //Wire corutine commands
  CorutineM.Co <- AppC.Co;
  //Wire boot
  AppC -> MainC.Boot;  
  //Wire leds
  AppC.Leds -> LedsC;
  //Wire protocol
  AppC.WhoP -> WhoP;
  AppC.WhoAckP -> WhoAckP;
  AppC.RandomP -> RandomP;
  //Wire to start radio from application
  AppC.AMControl -> ActiveMessageC;
  //Wire random
  AppC.RandomInit -> RandomC.SeedInit;
  AppC.Random-> RandomC.Random;

}

