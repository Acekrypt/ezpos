/* -*- Mode: C++; tab-width: 8; indent-tabs-mode: t; c-basic-offset: 8 -*- */
/*
 * $Id: pole.c 154 2004-06-03 15:45:25Z nas $ 
 * Copyright (C) 2002 Nathan Stitt  
 * See file COPYING for use and distribution permission.
 */

#include <ruby.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <errno.h>
#include <unistd.h>
#include <termios.h>

static VALUE rbClass;
struct termios newtio;


static const char RESET_COMMAND=0x0B;
static const char CURSOR_OFF_COMMAND=0x14;
static const char MODE_COMMAND=0x11;
static const char LINE_LEN=20;
static const char SET_MODE=0x11;
typedef struct _jkplay {
	int fd;
	char line_one[ 21 ];
	char line_two[ 21 ];
} Display;




void
close_and_clear( void *dp ){
	Display *d=(Display*)dp;
	write( d->fd,&RESET_COMMAND,1 );
	write( d->fd, &CURSOR_OFF_COMMAND,1);
	close( d->fd );
 	free(d);
}

inline void
update_display( Display *d ){
	write( d->fd,&RESET_COMMAND,1 );
	
	write( d->fd, d->line_one, LINE_LEN );
	write( d->fd, d->line_two, LINE_LEN );
	write( d->fd, &CURSOR_OFF_COMMAND,1);
}

static VALUE
Pole_reset( VALUE self ){
	Display *d;
	Data_Get_Struct(self, Display, d);
	write( d->fd,&RESET_COMMAND,1 );
	return Qnil;
}



static VALUE
Pole_set_line_one( VALUE self, VALUE str ){
	Check_Type(str,T_STRING);
	Display *d;
	int i;
	Data_Get_Struct(self, Display, d);
	strncpy( d->line_one, RSTRING(str)->ptr, LINE_LEN );
	for ( i=RSTRING(str)->len; i<=LINE_LEN; ++i ){
		d->line_one[i] = ' ';
	}
	d->line_one[LINE_LEN] = '\0';
	update_display( d );
	return str;
}


static VALUE
Pole_get_line_one( VALUE self, VALUE str ){
	Display *d;
	Data_Get_Struct(self, Display, d);
	return  rb_str_new2( d->line_one );
}

static VALUE
Pole_set_line_two( VALUE self, VALUE str ){
	Check_Type(str,T_STRING);
	Display *d;
	int i;
	Data_Get_Struct(self, Display, d);
	strncpy( d->line_two, RSTRING(str)->ptr, LINE_LEN);

	for ( i=RSTRING(str)->len; i<=LINE_LEN; ++i ){
		d->line_two[i] = ' ';
	}
	d->line_two[LINE_LEN] = '\0';
	update_display( d );

	return str;

}


static VALUE
Pole_get_line_two( VALUE self, VALUE str ){
	Display *d;
	Data_Get_Struct(self, Display, d);
	return  rb_str_new2( d->line_two );
}



static VALUE
Pole_new( VALUE self, VALUE file_name ){
	Display *d=malloc( sizeof( Display ) );


	Check_Type(file_name,T_STRING);
	d->fd = open( RSTRING(file_name)->ptr , O_WRONLY | O_NOCTTY );
	bzero(&newtio, sizeof(newtio)); /* clear struct for new port settings */
	newtio.c_cflag = 3261;
	tcsetattr(d->fd,TCSANOW,&newtio);

	if ( d->fd < 0 ) {
		rb_raise( rb_eStandardError, strerror( errno ) );
	}
	VALUE data = Data_Wrap_Struct(self, 0, close_and_clear, d );
	write( d->fd,&RESET_COMMAND,1 );
	write( d->fd, &CURSOR_OFF_COMMAND,1);


	rb_define_const( self, "LINE_LENGTH",CHR2FIX( LINE_LEN-1 ) );

	return data;
}



void
Init_LCDisplayPole(){
	rbClass = rb_define_class("LCDisplayPole", rb_cObject );

	rb_define_singleton_method(rbClass, "new", Pole_new, 1);
	rb_define_method(rbClass, "reset", Pole_reset, 0);
	rb_define_method(rbClass, "line_one=", Pole_set_line_one, 1);
	rb_define_method(rbClass, "line_one", Pole_get_line_one, 0);
	rb_define_method(rbClass, "line_two=", Pole_set_line_two, 1);
	rb_define_method(rbClass, "line_two", Pole_get_line_two, 0);
}



