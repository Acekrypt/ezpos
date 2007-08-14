/* -*- Mode: C++; tab-width: 8; indent-tabs-mode: t; c-basic-offset: 8 -*- */
/*
 * $Id: charge.cc 562 2005-02-07 18:11:21Z nas $ 
 * Copyright (C) 2002 Nathan Stitt  
 * See file COPYING for use and distribution permission.
 */


#include <iostream>
#include "ruby.h"
#include <boost/tokenizer.hpp>
#include <string>
#include <map>
#include "boost/lexical_cast.hpp"
#include "LinkPointTransaction.h"
#include "LPOrderPart.h"

#define RB_METHOD(func) ((VALUE (*)(...))func)

static VALUE rb_cCharge;

static const VALUE parent_module = rb_eval_string("NAS::Payment::CreditCard");
static const ID rb_method_charging_transaction = rb_intern("charging_transaction");
static const ID rb_method_amount = rb_intern("amount");
static const ID rb_method_to_s = rb_intern("to_s");

using namespace std;

VALUE
Charge_from_batch( VALUE self, VALUE batch ){
 
	char buf[4096];
	LinkPointTransaction lpt;

	lpt.setClientCertificatePath( STR2CSTR( rb_eval_string("NAS::LocalConfig::YOUR_PAY_CERT_PATH") ) );
	lpt.setHost( STR2CSTR( rb_eval_string("NAS::LocalConfig::YOUR_PAY_HOST") ) );
	lpt.setPort( FIX2INT( rb_eval_string("NAS::LocalConfig::YOUR_PAY_PORT") ) );

	// Create an empty order
	LPOrderPart& order = LPOrderFactory::createOrderPart("order");
	
	// Create a part we wanna use to build the order
	LPOrderPart& op = LPOrderFactory::createOrderPart();

	// Build 'orderoptions'
	// For a test, set result to GOOD, DECLINE, or DUPLICATE
	//	op.put("result","GOOD");

	op.put("ordertype","POSTAUTH");

	// add 'orderoptions to order
	order.addPart("orderoptions", op );

	// Build 'merchantinfo'
	op.clear();
	op.put("configfile", STR2CSTR( rb_eval_string("NAS::LocalConfig::YOUR_PAY_ID") ) );
	// add 'merchantinfo to order
	order.addPart("merchantinfo", op );

	// Build 'payment'
	op.clear();
	op.put("chargetotal",STR2CSTR( rb_funcall( rb_funcall( batch, rb_method_amount,0 ), rb_method_to_s,0 ) ) );
	// add 'payment to order
	order.addPart("payment", op );

	VALUE trans = rb_funcall( batch,rb_method_charging_transaction, 0 );

	// Add oid
	op.clear();
	op.put("oid", STR2CSTR( trans ) );
	// add 'transactiondetails to order
	order.addPart("transactiondetails", op );

	// Process the order
	buf[0]='\0';
	order.toXML(buf);
	std::string rsp_str = lpt.send(buf);

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


	delete &op;
	delete &order;

	return results;
}



VALUE
Charge_from_authorization( VALUE self, VALUE authorization, VALUE amount ){
 
	char buf[4096];
	LinkPointTransaction lpt;

	lpt.setClientCertificatePath( STR2CSTR( rb_eval_string("NAS::LocalConfig::YOUR_PAY_CERT_PATH") ) );
	lpt.setHost( STR2CSTR( rb_eval_string("NAS::LocalConfig::YOUR_PAY_HOST") ) );
	lpt.setPort( FIX2INT( rb_eval_string("NAS::LocalConfig::YOUR_PAY_PORT") ) );

	// Create an empty order
	LPOrderPart& order = LPOrderFactory::createOrderPart("order");
	
	// Create a part we wanna use to build the order
	LPOrderPart& op = LPOrderFactory::createOrderPart();

	// Build 'orderoptions'
	// For a test, set result to GOOD, DECLINE, or DUPLICATE
	//	op.put("result","GOOD");

	op.put("ordertype","POSTAUTH");

	// add 'orderoptions to order
	order.addPart("orderoptions", op );

	// Build 'merchantinfo'
	op.clear();
	op.put("configfile", STR2CSTR( rb_eval_string("NAS::LocalConfig::YOUR_PAY_ID") ) );
	// add 'merchantinfo to order
	order.addPart("merchantinfo", op );

	// Build 'payment'
	op.clear();
	op.put("chargetotal",STR2CSTR( rb_funcall( amount, rb_method_to_s,0 ) ) );
	// add 'payment to order
	order.addPart("payment", op );


	// Add oid
	op.clear();
	op.put("oid", STR2CSTR( authorization ) );
	// add 'transactiondetails to order
	order.addPart("transactiondetails", op );

	// Process the order
	buf[0]='\0';
	order.toXML(buf);

	std::cout << buf << std::endl;

	std::string rsp_str = lpt.send(buf);

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

 
	delete &op;
	delete &order;

	return results;
}

extern "C"
void
Init_charge(){
	rb_cCharge = rb_define_class_under(parent_module, "Charge", rb_cObject );
	rb_define_singleton_method( rb_cCharge, "from_batch", RB_METHOD(Charge_from_batch), 1 );
	rb_define_singleton_method( rb_cCharge, "from_authorization", RB_METHOD(Charge_from_authorization), 2 );
}


