module RadioResP
{
provides interface SetGetI<bool> as SetGetI;
}
implementation
{

bool busy=FALSE;
message_t pkt;

command void SetGetI.set(bool b)
{
	busy=b;
}

command bool SetGetI.get()
{
	return busy;
}

command message_t *SetGetI.get_message_t()
{
	return &pkt;
}


}

