######################################################################################################
############                    Created By: Yuval Lando                    ###########################
######################################################################################################

$fileName=$ARGV[0];
$headerName=$ARGV[1];

open (msgTypesFile,"$fileName");
while ($msgType=<msgTypesFile>)
{
	chomp($msgType);
if (!($msgType eq "")){
system("mig java -target=null -java-classname=$msgType $headerName $msgType -o $msgType.java");
system("javac $msgType.java");
	}
}
close(msgTypesFile);
