//******************************************************************************
// File Name: shell.h
// Description: 프로그램에 있는 모든 스레드를 정의한다.
//******************************************************************************
#ifndef _SHELL_H_
#define _SHELL_H_

#define        NUL        0x00 
#define        SOH        0x01 
#define        STX        0x02 
#define        ETX        0x03 
#define        EOT        0x04 
#define        ENQ        0x05 
#define        ACK        0x06 
#define        BEL        0x07 
#define        BS         0x08 
#define        HT         0x09 
#define        LF         0x0a 
#define        VT         0x0b 
#define        FF         0x0c 
#define        CR         0x0d 
#define        SO         0x0e 
#define        SI         0x0f 
#define        DLE        0x10 
#define        DC1        0x11 
#define        DC2        0x12 
#define        DC3        0x13 
#define        DC4        0x14 
#define        NAK        0x15 
#define        SYN        0x16 
#define        ETB        0x17 
#define        CAN        0x18 
#define        EM         0x19 
#define        SUB        0x1a 
#define        ESC        0x1b 
#define        FS         0x1c 
#define        GS         0x1d 
#define        RS         0x1e 
#define        US         0x1f 
#define        DEL        0x7f

typedef struct {
    char *CmdStr;                     	    // 명령 문자열
    int  (*func)(int argc, char **argv);	// 수행 함수
	char *HelpStr; 
} TCommand;

extern TCommand Cmds[];

#ifdef __cplusplus
extern "C" {
#endif

void shell_program(void);
void shell_process(void);
int shell_execute(char *str);

void GoProgram(void *entry);
void MemoryHexDump( void *address, int size );
void PrintCommandHelp(char *cmd);
void PrintCommandUsage(char *cmd);

int ZModemCmd(int argc, char **argv);
int FlashWriteCmd(int argc, char **argv);
int GoCmd(int argc, char **argv);

#if defined(CONFIG_TST_MLCC)
int ClsMem(int argc, char **argv);
int TstConsoleCmd(int argc, char **argv);
#endif
int TestCmd(int argc, char **argv);
int ExitCmd(int argc, char **argv);
int HelpCmd(int argc, char **argv);
int MemoryDumpCmd(int argc, char **argv);
int ReadCharCmd(int argc, char **argv);
int ReadWordCmd(int argc, char **argv);
int ReadLongCmd(int argc, char **argv);
int WriteCharCmd(int argc, char **argv);
int WriteWordCmd(int argc, char **argv);
int WriteLongCmd(int argc, char **argv);

// 2015.12.22
int ReadSerial(char* str);
void WriteSerial(char* str);
int ReadSerial_stop(void);
int dprint(const char *fmt, ...);



#ifdef __cplusplus
}
#endif

#endif // _SHELL_H_
