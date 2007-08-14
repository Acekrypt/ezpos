// LinkPointTransaction.h: interface for the LinkPointTransaction class.

//

//////////////////////////////////////////////////////////////////////



#if !defined _LINKPOINTTRANSACTION_HPP
#define _LINKPOINTTRANSACTION_HPP



#ifdef WIN32
#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

#endif





#define SBUFSIZE 8192

class LinkPointTransaction

{

public:



	LinkPointTransaction();

	LinkPointTransaction(char* sClientCertPath, char* sHost, int iPort);

	virtual ~LinkPointTransaction();



	// This guy does the job

	char*    send(char* sXml);
	char*    send(char* sClientCertPath, char* sHost, int iPort, char* sXml);

    char*    getVersion();

	// Setters/Getters

	void  setClientCertificatePath(char *path);

	char* getClientCertificatePath();

	void  setServerCertificatePath(char *path);

	char* getServerCertificatePath();

	void  setHost(char *host);

	char* getHost();

	void  setPort(int port);

	int   getPort();



protected:





    char    m_szServerCertPath[255];

    char    m_szClientCertPath[255];

    char    m_szHost[128];

	int     m_iPort;

	char    m_szXMLResponse[SBUFSIZE];





	// helpers

	void    init();

	bool  validate(char *xml);



};



#endif // !defined(AFX_LINKPOINTTRANSACTION_H__33611D74_3BCC_488D_B76B_9AB45AEFB351__INCLUDED_)

