/* -*- Mode: C++; tab-width: 8; indent-tabs-mode: t; c-basic-offset: 8 -*- */
/*
 * $Id$ 
 * Copyright (C) 2002 Nathan Stitt  
 * See file COPYING for use and distribution permission.
 */

#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <termios.h>
#include <stdio.h>

/* baudrate settings are defined in <asm/termbits.h>, which is
   included by <termios.h> */

/* change this definition for the correct port */
#define MODEMDEVICE "/dev/ttyS0"
#define _POSIX_SOURCE 1 /* POSIX compliant source */

#define FALSE 0
#define TRUE 1

volatile int STOP=FALSE; 


#include <signal.h>
#include <stdio.h>
#include <stdlib.h>




struct termios oldtio,newtio;
int fd;

/* The signal handler just clears the flag and re-enables itself. */
void 
catch_sig (int sig)
{
	printf("Cleaning up\n");

	/* restore the old port settings */
	tcsetattr(fd,TCSANOW,&oldtio);

	exit(0);
}

void cp( char *from, char *to ){
	int i;
	strncpy( to, from, 20 );
	for ( i = strlen( from ); i <= 20; ++i ) {
		to[i]=' ';
	}
}

int
main(int argc, char** argv)
{

	if ( argc < 7 ){
		printf("Not all args given\n");
		exit (1);
	}

	/* Establish a handler for SIGALRM signals. */
	//	signal (SIGINT, catch_sig);

        /* 


	   Open modem device for reading and writing and not as controlling tty
	   because we don't want to get killed if linenoise sends CTRL-C.
        */
	fd = open(MODEMDEVICE, O_RDWR | O_NOCTTY ); 
	if (fd  <0) {perror(MODEMDEVICE); exit(-1); }

	tcgetattr(fd,&oldtio); /* save current serial port settings */

	bzero(&newtio, sizeof(newtio)); /* clear struct for new port settings */
 
        /* 
	   BAUDRATE: Set bps rate. You could also use cfsetispeed and cfsetospeed.
	   CRTSCTS : output hardware flow control (only used if the cable has
	   all necessary lines. See sect. 7 of Serial-HOWTO)
	   CS8     : 8n1 (8bit,no parity,1 stopbit)
	   CLOCAL  : local connection, no modem contol
	   CREAD   : enable receiving characters
        */
	newtio.c_cflag = 3261;//B9600 | CS8 | CREAD;



	char msg[20];

	int first_sleep, second_sleep;
	first_sleep=atoi( argv[1] );
	second_sleep=atoi( argv[2] );

	sleep( first_sleep );

	char reset=0x1F;
	char no_curs=20;
	write( fd,&reset,1);
  	write( fd, &no_curs,1);

	cp( argv[3], msg );
 	write( fd,msg,20);

	cp( argv[4], msg );
 	write( fd,msg,19);

	sleep( second_sleep );

	write( fd,&reset,1);
  	write( fd, &no_curs,1);

	cp( argv[5], msg );
 	write( fd,msg,20);

	cp( argv[6], msg );
 	write( fd,msg,19);


	close(fd);

}

