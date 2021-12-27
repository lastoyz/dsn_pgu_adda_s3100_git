// CmdToken.cpp: implementation of the CCmdToken class.
//
//////////////////////////////////////////////////////////////////////

//#include "stdafx.h"
#include "CmdToken.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>


//////////////////////////////////////////////////////////////////////
// Construction/Destruction
//////////////////////////////////////////////////////////////////////
 
CCmdToken::CCmdToken()
{
  strcpy(m_CmdDelimit, ":");
  strcpy(m_ParaDelimit, ",");    
  Clear();
}


CCmdToken::~CCmdToken()
{
 
}


void CCmdToken::Clear()
{
  m_CmdCount = 0;
  m_ParaCount = 0;
  memset(m_CmdData,  0, MSG_CMD_SIZE);
  memset(m_ParaData, 0, MSG_PARA_SIZE);
}


void CCmdToken::SetDelimit(char *CmdDelimit, char *ParaDelimit)
{
  strcpy(m_CmdDelimit, CmdDelimit);
  strcpy(m_ParaDelimit, ParaDelimit);  
}


void CCmdToken::Token(char *tokenData)
{
	char *tok;

	m_CmdCount = 0;
	m_ParaCount = 0;
	m_CmdData[0] = NULL;
	m_ParaData[0] = NULL;

	strcpy(m_CmdData, tokenData);
	tok = strtok(m_CmdData, " \r");  
	if (tok == NULL) return;

	tok = strtok(NULL, "\r");
	if (tok != NULL)
	{
		strcpy(m_ParaData, tok);
	}

	// Token CmdData
	tok = strtok(m_CmdData, m_CmdDelimit);
	while(tok != NULL)
	{
		m_Cmd[m_CmdCount++] = tok;
		tok = strtok(NULL, m_CmdDelimit);
	}

	if (m_ParaData[0] == NULL) return;

	// Token CmdData
	tok = strtok(m_ParaData, m_ParaDelimit); //2015.12 : m_ParaDelimit -> " "
	while(tok != NULL)
	{
		m_Para[m_ParaCount++] = tok;
		tok = strtok(NULL, m_ParaDelimit); //2015.12 : m_ParaDelimit -> " "
	}
}


BOOL CCmdToken::IsEQCmd(int nIndex, char *str)
{
  if ((nIndex < 0) || (nIndex >= m_CmdCount)) return FALSE;

  if (strcmp(m_Cmd[nIndex], str) != 0) return FALSE;

  return TRUE;
}


BOOL CCmdToken::IsEQPara(int nIndex, char *str)
{
  if ((nIndex < 0) || (nIndex >= m_ParaCount)) return FALSE;

  if (strcmp(m_Para[nIndex], str) != 0) return FALSE;

  return TRUE;
}




