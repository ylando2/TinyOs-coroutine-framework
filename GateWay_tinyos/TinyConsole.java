/*****************************************************************************************************
*************                   Created By: Yuval Lando                    ***************************
*****************************************************************************************************/


import java.io.IOException;
import net.tinyos.message.*;
import net.tinyos.packet.*;
import net.tinyos.util.*;
import java.io.*;

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
	try {
	//Sending the message
	moteIF.send(target, msg);
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
