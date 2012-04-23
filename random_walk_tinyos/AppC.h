/*****************************************************************************************************
*************                   Created By: Yuval Lando                    ***************************
*****************************************************************************************************/

#ifndef AppC12321_H
#define AppC12321_H

//one second
#define WAIT_TIME 1000
// 1/5 of a second
#define RADIO_WAIT 200
// 1/20 of a second
#define INTERVAL 50

//constants
enum {
//3 types of messages
  WHO_MSG,
  WHO_ACK_MSG,
  RANDOM_MSG
};

//Every struct in message must be nx_struct
//and every type must be nx_type

//Definition of message struct
typedef nx_struct {
 nx_uint8_t id;
} Who;

typedef nx_struct {
//variable to make the size of the message odd
nx_uint8_t make_odd_size; 
nx_uint8_t id;
nx_uint8_t targetId;
} WhoAck;

typedef nx_struct {
//variable to make the size of the message odd
nx_uint8_t make_odd_size; 
nx_uint8_t targetId;
nx_uint8_t index;
} RandomMsg;

typedef union {
Who who;
WhoAck whoAck;
RandomMsg randomMsg;
} UMsg;

#endif
