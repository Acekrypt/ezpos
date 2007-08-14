/* -*- Mode: C++; tab-width: 8; indent-tabs-mode: t; c-basic-offset: 8 -*- */
/*
 * $Id: yourpay.cc 1497 2006-01-18 20:56:31Z nas $ 
 * Copyright (C) 2002 Nathan Stitt  
 * See file COPYING for use and distribution permission.
 */


#include <iostream>
#include <fstream>

#include "ruby.h"
#include <boost/tokenizer.hpp>
#include <string>
#include <map>
#include "boost/lexical_cast.hpp"
#include "LinkPointTransaction.h"
#include "LPOrderPart.h"

#define RB_METHOD(func) ((VALUE (*)(...))func)

static const ID rb_method_charging_transaction = rb_intern("charging_transaction");
static const ID rb_method_to_s = rb_intern("to_s");

static const ID rb_method_credit_card = rb_intern("credit_card");

static const ID rb_method_authorize_amount = rb_intern("authorize_amount");
static const ID rb_method_card_number = rb_intern("number");
static const ID rb_method_card_year = rb_intern("year");
static const ID rb_method_card_month = rb_intern("mon");
static const ID rb_method_ip = rb_intern("ip_addr");
static const ID rb_method_name = rb_intern("name");
static const ID rb_method_address = rb_intern("authorization_address");
static const ID rb_method_city = rb_intern("city");
static const ID rb_method_state = rb_intern("state");
static const ID rb_method_zip = rb_intern("zip");
static const ID rb_method_country = rb_intern("country");


using namespace std;

void
replace( std::string &str, char sought, const std::string &replacement ) {
	std::string::size_type pos=0;
	int count=0;
	while ( count++ < 10 && pos != std::string::npos ){
		pos = str.find(sought,pos+1);
		if ( pos !=std::string::npos && ( (  pos > ( str.size() - 4 ) ) || str.substr( pos, 5 ) != "&amp;" ) ){
			str.replace(pos, 1, replacement);
		}
	}
}


char*
quote_xml( std::string &temp, const std::string &quote ) {
	temp=quote;
	replace( temp, '&', "&amp;");
	replace( temp, '<', "&lt;");
	return const_cast<char*>( temp.c_str() );
}


void
set_up_order( LPOrderPart &order, LPOrderPart& op, VALUE total, VALUE card, VALUE year, VALUE month ){

	// Build 'creditcard'
	op.clear();
	op.put("cardnumber", STR2CSTR( card ) );
	op.put("cardexpmonth", STR2CSTR( month ) );
	op.put("cardexpyear", STR2CSTR( year ) );
	
	// add 'creditcard to order
	order.addPart("creditcard", op );

	// Build 'merchantinfo'
	op.clear();
	op.put("configfile", STR2CSTR( rb_eval_string("::DEF::YOUR_PAY_ID") ) );
	// add 'merchantinfo to order
	order.addPart("merchantinfo", op );

	// Build 'payment'
	op.clear();
	op.put("chargetotal",STR2CSTR( rb_funcall( total, rb_method_to_s,0 ) ) );

	// add 'payment to order
	order.addPart("payment", op );

}

void 
set_link_point( LinkPointTransaction &lpt ){
	lpt.setClientCertificatePath( STR2CSTR( rb_eval_string("::DEF::YOUR_PAY_CERT_PATH") ) );
	lpt.setHost( STR2CSTR( rb_eval_string("::DEF::YOUR_PAY_HOST") ) );
	lpt.setPort( FIX2INT( rb_eval_string("::DEF::YOUR_PAY_PORT") ) );
}

VALUE
decode_results( std::string &rsp_str ){
	VALUE results = rb_hash_new();

	typedef boost::tokenizer<boost::char_separator<char> > tokenizer;
 	boost::char_separator<char> sep("<>","", boost::keep_empty_tokens);
	tokenizer tokens(rsp_str, sep);

	for (tokenizer::iterator tok_iter = tokens.begin(); tok_iter != tokens.end(); ++tok_iter){
	       	++tok_iter;
		if ( tok_iter == tokens.end() ){
			break;
		}
		std::string name = *tok_iter;
		++tok_iter;
		rb_hash_aset( results, rb_str_new2(name.substr(2).c_str() ),  rb_str_new2( tok_iter->c_str() ) );
 		++tok_iter;
	}

	return results;
}

VALUE
face_to_face_charge( VALUE self, VALUE trans, VALUE amt ){
	char buf[4096];

	LinkPointTransaction lpt;
	set_link_point(lpt);

	// Create an empty order
	LPOrderPart& order = LPOrderFactory::createOrderPart("order");
	// Create a part we wanna use to build the order
	LPOrderPart& op = LPOrderFactory::createOrderPart();

	//	set_up_order( order, op, amount, card_number, year, month );

	// Build 'merchantinfo'
	op.clear();
	op.put("configfile", STR2CSTR( rb_eval_string("::DEF::YOUR_PAY_ID") ) );
	// add 'merchantinfo to order
	order.addPart("merchantinfo", op );

	op.clear();
	op.put("ordertype","POSTAUTH");

	// add 'orderoptions to order
	order.addPart("orderoptions", op );

	// Add oid
	op.clear();
	op.put("oid", STR2CSTR( trans ) );
	// add 'transactiondetails to order
	order.addPart("transactiondetails", op );

	// Build 'payment'
	op.clear();
	op.put("chargetotal",STR2CSTR( rb_funcall( amt, rb_method_to_s,0 ) ) );

	// add 'payment to order
	order.addPart("payment", op );

	// Process the order
	buf[0]='\0';

	order.toXML(buf);

	std::string rsp_str = lpt.send(buf);
	std::ofstream file("/tmp/cc_process.log", ios::out );
	if ( file.is_open() ) {
		file << "--------------------------------------------------------\n"
		     << buf << std::endl;
		file << "--------------------------------------------------------\n"
		     << "Result: " << rsp_str << std::endl;
		file.close();
	}

	delete &op;
	delete &order;

	return decode_results( rsp_str );
}



VALUE
face_to_face_auth( VALUE self, VALUE amount, VALUE card_number, VALUE month, VALUE year ) {
	char buf[4096];

	LinkPointTransaction lpt;
	set_link_point(lpt);

	// Create an empty order
	LPOrderPart& order = LPOrderFactory::createOrderPart("order");
	// Create a part we wanna use to build the order
	LPOrderPart& op = LPOrderFactory::createOrderPart();

	set_up_order( order, op, amount, card_number, year, month );

	op.clear();
	op.put("ordertype","PREAUTH");

	// add 'orderoptions to order
	order.addPart("orderoptions", op );


	// Build 'transactiondetails'
	op.clear();
	op.put("terminaltype","POS");
	op.put("transactionorigin","RETAIL");
	order.addPart("transactiondetails", op );

	// Process the order
	buf[0]='\0';

	order.toXML(buf);

	std::string rsp_str = lpt.send(buf);
	std::ofstream file("/tmp/cc_process.log", ios::out );
	if ( file.is_open() ) {
		file << "--------------------------------------------------------\n"
		     << buf << std::endl;
		file << "--------------------------------------------------------\n"
		     << "Result: " << rsp_str << std::endl;
		file.close();
	}

	delete &op;
	delete &order;

	return decode_results( rsp_str );
}


VALUE
authorize_from_internet( VALUE self, VALUE rb_order, VALUE rb_card ){
	char buf[4096];
	std::string temp_str;

	LinkPointTransaction lpt;
	set_link_point(lpt);

	// Create an empty order
	LPOrderPart& order = LPOrderFactory::createOrderPart("order");
	// Create a part we wanna use to build the order
	LPOrderPart& op = LPOrderFactory::createOrderPart();

	set_up_order( order, op,
		      rb_funcall( rb_order, rb_method_authorize_amount,1,rb_card ),
		      rb_funcall( rb_card, rb_method_card_number,0 ),
		      rb_funcall( rb_card, rb_method_card_year,0 ),
		      rb_funcall( rb_card, rb_method_card_month,0 )
		      );

	op.clear();
	op.put("ordertype","PREAUTH");
	// add 'orderoptions to order
	order.addPart("orderoptions", op );

 	// Build 'billing'
 	op.clear();
 	op.put("name",quote_xml( temp_str, STR2CSTR( rb_funcall( rb_card, rb_method_name,0 ) ) ) );
 	op.put("address1",quote_xml( temp_str, STR2CSTR( rb_funcall( rb_card, rb_method_address, 0 ) ) ) );
  	op.put("city",quote_xml( temp_str, STR2CSTR( rb_funcall( rb_card, rb_method_city,0 ) ) ) );
  	op.put("state",quote_xml( temp_str, STR2CSTR( rb_funcall( rb_card, rb_method_state,0 ) ) ) );
  	op.put("zip",quote_xml( temp_str, STR2CSTR( rb_funcall( rb_card, rb_method_zip,0 ) ) ) );
  	op.put("country",quote_xml( temp_str, STR2CSTR( rb_funcall( rb_card, rb_method_country,0 ) ) ) );
	op.put("addrnum",quote_xml( temp_str,  STR2CSTR( rb_funcall( rb_card, rb_method_address, 0 ) ) ) );
 	// add 'billing to order
 	order.addPart("billing", op );

	// Build 'transactiondetails'
	op.clear();
	op.put("terminaltype","UNSPECIFIED");
	op.put("transactionorigin","ECI");
	op.put("ip", STR2CSTR( rb_funcall( rb_order, rb_method_ip,0 ) ) );
	order.addPart("transactiondetails", op );

	// Process the order
	buf[0]='\0';

	order.toXML(buf);
	std::string rsp_str = lpt.send(buf);

	std::ofstream file("/tmp/cc_process.log", ios::out );
	if ( file.is_open() ) {
		file << "--------------------------------------------------------\n"
		     << buf << std::endl;
		file << "--------------------------------------------------------\n"
		     << "Result: " << rsp_str << std::endl;
		file.close();
	}

	delete &op;
	delete &order;

	return decode_results( rsp_str );
}

extern "C"
void
Init_c_yourpay(){
	VALUE rb_mYourPay;
	rb_mYourPay = rb_define_module ("CYourPay");

	rb_define_module_function( rb_mYourPay, "FaceToFaceAuthorization", RB_METHOD(face_to_face_auth), 4 );
	rb_define_module_function( rb_mYourPay, "AuthorizeFromInternet", RB_METHOD(authorize_from_internet), 2 );
	rb_define_module_function( rb_mYourPay, "ChargeFace2FaceAuthorization", RB_METHOD(face_to_face_charge), 2 );
}


