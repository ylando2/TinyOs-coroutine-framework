#include "AppC.h"

generic module Serial_protocolP(typedef msgType)
{
  provides interface ProtocolI<msgType> as P;
  //Sending,receiving and packet handling commands
  uses interface Packet;
  uses interface AMSend as Send;
  uses interface Receive;
  uses interface SetGetI<bool> as Busy;
}
implementation
{
 

//Send local protocol msg
void command P.send(msgType *m)
  {
      message_t *pkt=call Busy.get_message_t();
      //Dont send a message untill it finish sending the last message
      if (!call Busy.get()) {
      //Allocating memory for message
      msgType *local_pkt = 
       (msgType *)(call Packet.getPayload(pkt, NULL));
      //Initialize header
      *local_pkt = *m;
      //If success in calling sending function,the node is busy sending
      if (call Send.send(AM_BROADCAST_ADDR, 
          pkt, sizeof(msgType)) == SUCCESS) {
        call Busy.set(TRUE);
      }
    }
  } 


//Receiving local message
  event message_t* Receive.receive(message_t* msg, void* payload, uint8_t len){
    //Handle error in msg
    if (len == sizeof(msgType)) {
      msgType* btrpkt = (msgType*)payload;
    signal P.receive(btrpkt);
    }
    return msg;
}

  event void Send.sendDone(message_t* msg, error_t err) {
  //If the message has been sent the radio is not busy any more
    message_t *pkt=call Busy.get_message_t();
    if (pkt == msg) {
      call Busy.set(FALSE);
    }
  }
}

