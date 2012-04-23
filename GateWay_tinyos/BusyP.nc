/*****************************************************************************************************
*************                   Created By: Yuval Lando                    ***************************
*****************************************************************************************************/

module BusyP
{
provides interface SetGetI<bool> as SetGetI;
}
implementation
{

bool busy=FALSE;

command void SetGetI.set(bool b)
{
	busy=b;
}

command bool SetGetI.get()
{
	return busy;
}

}

