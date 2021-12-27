// CmdToken.h: interface for the CCmdToken class.
//
//////////////////////////////////////////////////////////////////////
#ifndef AFX_CMDTOKEN_H__DA7D94AC_8C82_47D3_A368_43CDD8BB1F3B__INCLUDED_
#define AFX_CMDTOKEN_H__DA7D94AC_8C82_47D3_A368_43CDD8BB1F3B__INCLUDED_
//#if _MSC_VER > 1000
//#pragma once
//#endif // _MSC_VER > 1000

#include "UserDefine.h"


#define MSG_CMD_MAX     40
#define MSG_PARA_MAX    40 //2015.12.22
#define MSG_CMD_SIZE    4096
#define MSG_PARA_SIZE   4096

class CCmdToken 
{
public:
	CCmdToken();
	~CCmdToken();

// Attribute  
//private:
public:
  char        m_CmdData[MSG_CMD_SIZE];
  char        m_ParaData[MSG_PARA_SIZE];
  char        m_CmdDelimit[256];
  char        m_ParaDelimit[256];

public:
  int         m_CmdCount;
  int         m_ParaCount;
  char        *m_Cmd[MSG_CMD_MAX];
  char        *m_Para[MSG_PARA_MAX];
  
// Operation  
  void Clear();
  void SetDelimit(char *CmdDelimit, char *ParaDelimit);
  void Token(char *tokenData);  

  BOOL IsEQCmd(int nIndex, char *str);
  BOOL IsEQPara(int nIndex, char *str);

};

#endif // !defined(AFX_CMDTOKEN_H__DA7D94AC_8C82_47D3_A368_43CDD8BB1F3B__INCLUDED_)
