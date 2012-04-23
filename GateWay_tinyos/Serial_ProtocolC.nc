/*****************************************************************************************************
*************                   Created By: Yuval Lando                    ***************************
*****************************************************************************************************/

generic configuration Serial_ProtocolC(typedef msgType,uint8_t msgId)
{
 provides interface ProtocolI<msgType> as P;

}
implementation
{
  components new Serial_protocolP(msgType) as SerialP;
  components SerialActiveMessageC as AM;
  components SerialResP;

  SerialP.Packet -> AM;
  SerialP.Send -> AM.AMSend[msgId];
  SerialP.Receive -> AM.Receive[msgId];
  SerialP.Busy ->  SerialResP. SetGetI;

  P=SerialP.P;
}

