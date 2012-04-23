/*****************************************************************************************************
*************                   Created By: Yuval Lando                    ***************************
*****************************************************************************************************/

generic configuration Local_protocolC(typedef msgType,uint8_t msgId)
{
 provides interface ProtocolI<msgType> as P;

}
implementation
{
  components new Local_protocolP(msgType) as LocalP;
  components new AMSenderC(msgId);
  components new AMReceiverC(msgId);
  components RadioResP;

  LocalP.Packet -> AMSenderC;
  LocalP.AMPacket -> AMSenderC;
  LocalP.Send -> AMSenderC;
  LocalP.Receive -> AMReceiverC;
  LocalP.Busy ->  RadioResP. SetGetI;

  P=LocalP.P;
}

