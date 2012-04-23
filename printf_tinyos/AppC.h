/*****************************************************************************************************
*************                   Created By: Yuval Lando                    ***************************
*****************************************************************************************************/

#ifndef AppC12321_H
#define AppC12321_H

//constants
enum {
//local msg id
  LOCAL_MSG =1,

//Interval to wait for the radio to clear before sending
//the next message
  RADIO_INTERVAL = 200
};

//Every struct in message must be nx_struct
//and every type must be nx_type

//Definition of message struct
typedef nx_struct {
 nx_uint16_t counter;
} AppCMsg;


#endif
