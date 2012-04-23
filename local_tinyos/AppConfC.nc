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
  //Protocol (get msg type and msg id)
  components new Local_protocolC(AppCMsg,LOCAL_MSG) as LocalP;
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
  AppC.P -> LocalP.P;
  //Wire to start radio from application
  AppC.AMControl -> ActiveMessageC;
}

