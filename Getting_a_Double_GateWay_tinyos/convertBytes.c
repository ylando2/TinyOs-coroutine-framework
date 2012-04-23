/*****************************************************************************************************
*************                   Created By: Yuval Lando                    ***************************
*****************************************************************************************************/

#include <stdio.h>
#include "TinyConsole.h"   // this header file was generated by javah

JNIEXPORT double JNICALL Java_TinyConsole_convertBytes(JNIEnv *env, jobject obj
,jbyte b1
,jbyte b2
,jbyte b3
,jbyte b4
,jbyte b5
,jbyte b6
,jbyte b7
,jbyte b8) 
{
	//c double= c++ float
	float temp;
	jbyte *p=(jbyte *)&temp;
	p[0]=b1;
	p[1]=b2;
	p[2]=b3;
	p[3]=b4;
	p[4]=b5;
	p[5]=b6;
	p[6]=b7;
	p[7]=b8;
	return temp;
}

JNIEXPORT void JNICALL Java_TinyConsole_convertDouble(JNIEnv *env, jobject obj,jfloat num,jbyteArray arr)
//The byte array must not be a null
{
jbyte *b;
jbyte *p=(jbyte *)&num;
int i;
b=(*env)->GetByteArrayElements(env,arr,0);
for (i=0;i<8;i++)
	b[i]=p[i];
(*env)->ReleaseByteArrayElements(env,arr,b,0);
return;
}