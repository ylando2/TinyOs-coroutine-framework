/*****************************************************************************************************
*************                   Created By: Yuval Lando                    ***************************
*****************************************************************************************************/

interface CoCommandsI
{
  command uint32_t getTime();
  command void start();
  command bool sleep(uint32_t dt);
  command bool wait();
  command bool wait_time(uint32_t dt);
  command void notify(uint8_t coNum);
  command bool receive_block(uint8_t msgId);
  command void dispatch(uint8_t msgId);
  command bool receive_block_time(uint8_t msgId,uint32_t dt);
}

