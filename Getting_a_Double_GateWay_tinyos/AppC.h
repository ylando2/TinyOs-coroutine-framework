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

//message identifier
//need to contain the message name AM_(MSG_NAME_IN_BIG_LETTERS)
enum {
AM_APPCMSG
};

//Every struct in message must be nx_struct
//and every type must be nx_type.
//Every serial message must have the name of the type
//before and after the definition of the nx_struct

//Definition of message struct
typedef nx_struct AppCMsg{
 nx_uint8_t msg_counter;
 nx_uint8_t nodeId;
 nx_uint8_t number;
 nx_int8_t doubleArr0;
 nx_int8_t doubleArr1;
 nx_int8_t doubleArr2;
 nx_int8_t doubleArr3;
 nx_int8_t doubleArr4;
 nx_int8_t doubleArr5;
 nx_int8_t doubleArr6;
 nx_int8_t doubleArr7;

} AppCMsg;


#endif
