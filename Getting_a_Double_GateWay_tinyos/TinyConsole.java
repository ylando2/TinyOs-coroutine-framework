/*****************************************************************************************************
*************                   Created By: Yuval Lando                    ***************************
*****************************************************************************************************/

import java.io.IOException;
import net.tinyos.message.*;
import net.tinyos.packet.*;
import net.tinyos.util.*;
import java.io.*;


import java.io.ByteArrayOutputStream;
import java.io.DataOutputStream;
import java.io.ByteArrayInputStream;
import java.io.DataInputStream;


public class TinyConsole implements MessageListener {
 

// menu modes
  public static final int MENU=0;
  public static final int START=100;
  public static final int STARTPROS=101;
  public static final int SLEEP=200;
  public static final int SLEEPPROS=201;
  public static final int WAKE=300;
  public static final int WAKEPROS=301;

  //count the number of messages
  private short counter = 0;

  private MoteIF moteIF;
  
  public TinyConsole(MoteIF moteIF) {
    this.moteIF = moteIF;
    this.moteIF.registerListener(new PrintfMsg(), this);
    this.moteIF.registerListener(new AppCMsg(), this);
  }


private byte[] msgDoubleToArr(AppCMsg m)
{
byte[] temp=new byte[8];
temp[0]=m.get_doubleArr0();
temp[1]=m.get_doubleArr1();
temp[2]=m.get_doubleArr2();
temp[3]=m.get_doubleArr3();
temp[4]=m.get_doubleArr4();
temp[5]=m.get_doubleArr5();
temp[6]=m.get_doubleArr6();
temp[7]=m.get_doubleArr7();
return temp;
}

private void arrToMsg(byte[] b,AppCMsg m)
{
m.set_doubleArr0(b[0]);
m.set_doubleArr1(b[1]);
m.set_doubleArr2(b[2]);
m.set_doubleArr3(b[3]);
m.set_doubleArr4(b[4]);
m.set_doubleArr5(b[5]);
m.set_doubleArr6(b[6]);
m.set_doubleArr7(b[7]);
}

private byte[] doubleToBytes(float num)
{

		int lnum=Float.floatToIntBits(num);
		byte[] arr=new byte[8];
		int l=0xff;
		int i;
		for (i=0;i<8;i++)
		{
			arr[i]|=l&lnum;
			lnum>>=8;
		}
		return arr;
		
/*
	byte[] arr;

	ByteArrayOutputStream bytestream =
	new ByteArrayOutputStream();
	DataOutputStream datastream =
	new DataOutputStream(bytestream);
	try {
	datastream.writeFloat(num);
	datastream.flush();
	}

	catch (Exception e)
	{
	}

	arr = bytestream.toByteArray();
	return arr;
*/
}

public native double convertBytes(
byte b1,
byte b2,
byte b3,
byte b4,
byte b5,
byte b6,
byte b7,
byte b8
);

public native void convertDouble(float num,byte[] arr);

static 
  {
    System.loadLibrary("convertBytes"); 
  }

private double bytesToDouble(byte[] arr)
{
/*
		int accum=0;
		int l=0xff;
		int i;
		for (i=7;i>=0;i--)
		{
		    accum|=l&arr[i];
		    accum<<=8;
		}
		return Float.intBitsToFloat(accum);
*/
return convertBytes(
arr[0],
arr[1],
arr[2],
arr[3],
arr[4],
arr[5],
arr[6],
arr[7]);
/*
		float num=0;
		ByteArrayInputStream bytesin =
			new ByteArrayInputStream(arr);
		DataInputStream datain =
			new DataInputStream(bytesin);

		try
		{
			num = datain.readFloat();
		}
		catch (Exception e)
		{
		}
		return num;
*/
}


  public void menu() {
    InputStreamReader  inp = new InputStreamReader(System.in) ;	
    BufferedReader br = new BufferedReader(inp);
    String str="";
    short num=0;
 
    //Menu loop
    while (num!=2) {
	System.out.println("Press 1 to send message");
	System.out.println("Press 2 exit");
	try {
	str=br.readLine();
	}
	catch (Exception exception)
	{
	str="";
	}
	try  {
	num=Short.valueOf(str).shortValue();
	   
	
    switch(num) {

	case 2: break;

	case 1: sendNumber(); break;

	default: System.out.println("You enter a number that is out of range.");
		 System.out.println("Please try again.");
		break;
	 }//end switch
      
       }//end try
      catch (NumberFormatException exception) {
	System.out.println("wrong input");
	num=0;
	}//end catch
      }//end  while
   }//end menu

private void sendNumber()
{ 
     InputStreamReader  inp = new InputStreamReader(System.in) ;	
      BufferedReader br = new BufferedReader(inp);

 	AppCMsg msg = new AppCMsg();
        String str="";
        short num=0;
        int target=0;
  
	System.out.println("Enter a number");
	try{
	str=br.readLine();
	}
	catch(Exception exception)
	{
	str="";
	}
	 try  {
	num=Short.valueOf(str).shortValue();
	 }//end try
	catch (NumberFormatException exception) {
	System.out.println("wrong input");
	return;
	 }//end catch
	
	//sending the number
 	counter++;
	msg.set_msg_counter(counter);
	msg.set_nodeId((short)0);
	msg.set_number(num);
	byte[] arr={1,2,3,4,5,6,7,8};
	convertDouble((float)1.5,arr);
	arrToMsg(arr,msg);
	try {
	//Sending the message
	System.out.println("Sending message");
	moteIF.send(target, msg);
	System.out.println("Finish sending the message");
	//Wait one second before sending the next message
	try {Thread.sleep(1000);}
	catch (InterruptedException exception) {}
          }//end try
    catch (IOException exception) {
      System.err.println("Exception thrown when sending packets. Exiting.");
      System.err.println(exception);
    }//end catch

}//End send number


  public void messageReceived(int to, Message message) {
    //handle debug messages
    if (message instanceof PrintfMsg)
    {
    PrintfMsg msg = (PrintfMsg)message;
    for(int i=0; i<msg.totalSize_buffer(); i++) {
    	char nextChar = (char)(msg.getElement_buffer(i));
    	if(nextChar != 0)
    	System.out.print(nextChar);
    	}
    }

    if (message instanceof AppCMsg)
    {
    AppCMsg msg = (AppCMsg)message;
    System.out.println("Received packet sequence number " + msg.get_msg_counter());
    System.out.println("node id is:"+msg.get_nodeId());
    System.out.println("The number is:"+msg.get_number());
    byte arr[]=msgDoubleToArr(msg);
    double val=bytesToDouble(arr);
    System.out.println("$ The double return value is: $"+val); 
    } 
}
  
  private static void usage() {
    System.err.println("usage: TestSerial [-comm <source>]");
  }
  


  public static void main(String[] args) throws Exception {

    String source = null;
   //Check the arguments
    if (args.length == 2) {
      if (!args[0].equals("-comm")) {
	usage();
	System.exit(1);
      }
      source = args[1];
    }
    else if (args.length != 0) {
      usage();
      System.exit(1);
    }
    
    PhoenixSource phoenix;
    //Initialize program
    if (source == null) {
      phoenix = BuildSource.makePhoenix(PrintStreamMessenger.err);
    }
    else {
      phoenix = BuildSource.makePhoenix(source, PrintStreamMessenger.err);
    }

    MoteIF mif = new MoteIF(phoenix);
    TinyConsole app = new TinyConsole(mif);
    //run menu
    app.menu();
    System.exit(0);
  }


}
