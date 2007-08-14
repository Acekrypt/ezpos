#ifndef _LPORDERPART_H
#define _LPORDERPART_H

#include <stdlib.h>


class  LPOrderPart 
{
public:
	
	virtual ~LPOrderPart(){};

	// interface to set/get part name, e.a. "billing"
	virtual char* getPartName()=0;
	virtual void  setPartName(char *)=0;
	
	// Interface to handle key/value pairs
	virtual void  put(char* key, char* val)=0;
	virtual const char*  get(char* key)=0;
	virtual void  remove(char* key)=0;
	virtual void  removeAll()=0;

	// Interface to handle nested parts
	virtual void  addPart(char* key, LPOrderPart& val, int idx=-1)=0;
	virtual LPOrderPart&  getPart(char* key, int idx=-1)=0;
	virtual void  removePart(char* key, int idx=-1)=0;
	virtual void  removeAllParts()=0;

    // dumps content into XML format
	virtual char* toXML(char*buf)=0;

	// clears all content
	virtual void  clear(bool fl=true)=0;
 

};

typedef LPOrderPart LPOrder;

class LPOrderFactory
{
public:

 static LPOrderPart& createOrderPart(char *name=NULL);
};

#endif

