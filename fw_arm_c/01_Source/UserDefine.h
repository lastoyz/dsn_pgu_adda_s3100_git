#ifndef _USERDEFINE_H
#define	_USERDEFINE_H

#include	<stdio.h>
#include	<stdlib.h>
#include	<string.h>
#include	<stdarg.h>
#include	<math.h>

typedef				signed		char					s8,		*s8p;
typedef				signed		short					s16,	*s16p;
typedef				signed		long					s32,	*s32p;
typedef				signed		long	long			s64,	*s64p;


typedef				unsigned	char					u8,		*u8p;
typedef				unsigned	short					u16,	*u16p;
typedef				unsigned	long					u32,	*u32p;
typedef				unsigned	long	long			u64,	*u64p;


typedef				signed		char			const	sc8,	*sc8p;
typedef				signed		short			const	sc16,	*sc16p;
typedef				signed		long			const	sc32,	*sc32p;
typedef				signed		long	long	const	sc64,	*sc64p;


typedef				unsigned	char			const	uc8,	*uc8p;
typedef				unsigned	short			const	uc16,	*uc16p;
typedef				unsigned	long			const	uc32,	*uc32p;
typedef				unsigned	long	long	const	uc64,	*uc64p;


typedef	volatile	signed		char					vs8,	*vs8p,	VCHAR, *PVCHAR, VUINT8, *PVUINT8;
typedef	volatile	signed		short					vs16,	*vs16p, VINT16, *PVINT16;
typedef	volatile	signed		long					vs32,	*vs32p, VINT32, *PVINT32;
typedef	volatile	signed		long	long			vs64,	*vs64p, VINT64, *PVINT64;


typedef	volatile	unsigned	char					vu8,	*vu8p, VUCHAR, *PVUCHAR;
typedef	volatile	unsigned	short					vu16,	*vu16p, VUINT16, *PVUINT16;
typedef	volatile	unsigned	long					vu32,	*vu32p, VUINT32, *PVUINT32;
typedef	volatile	unsigned	long	long			vu64,	*vu64p, VUINT64, *PVUINT64;


typedef	volatile	signed		char			const	vsc8,	*vsc8p;
typedef	volatile	signed		short			const	vsc16,	*vsc16p;
typedef	volatile	signed		long			const	vsc32,	*vsc32p;
typedef	volatile	signed		long	long	const	vsc64,	*vsc64p;


typedef	volatile	unsigned	char			const	vuc8,	*vuc8p;
typedef	volatile	unsigned	short			const	vuc16,	*vuc16p;
typedef	volatile	unsigned	long			const	vuc32,	*vuc32p;
typedef	volatile	unsigned	long	long	const	vuc64,	*vuc64p;


typedef 			unsigned 	char 					UINT8, uint8;
typedef 						char 					INT8, int8;
typedef 			unsigned 	short 					UINT16, uint16;
typedef 						short 					INT16, int16;
typedef 			unsigned 	long 					UINT32, uint32;
typedef 						long 					INT32, int32;


//typedef 			unsigned 	char 					BOOL;



/* NandFlash MT29F basic data types */
typedef unsigned char        MT_uint8;
typedef signed char          MT_sint8;
typedef unsigned short       MT_uint16;
typedef signed short         MT_sint16;
typedef unsigned int         MT_uint32;
typedef signed int           MT_sint32;


#ifndef BOOL
//#define BOOL	int
#define BOOL	bool
#endif
#ifndef FALSE
//#define FALSE   0
#define FALSE   false
#endif
#ifndef TRUE
//#define TRUE    1
#define TRUE    true
#endif

typedef  void (*pFunc)(void);

typedef u8 (*tst_console_fn_t)(int, void*);

typedef struct _tst_console_cmd {
	const char *fn_name;
	tst_console_fn_t fn;
} tst_console_cmd_t;



typedef u8 (*tst_smu_console_fn_t)(void*, int, void*);

typedef struct _tst_smu_console_cmd {
	const char *fn_name;
	tst_smu_console_fn_t fn;
} tst_smu_console_cmd_t;

typedef	union{
	u8	u8Data;
	s8	s8Data;

	struct{
		u8	b0	:1;
		u8	b1	:1;
		u8	b2	:1;
		u8	b3	:1;
		u8	b4	:1;
		u8	b5	:1;
		u8	b6	:1;
		u8	b7	:1;
	};
}bitCtrl8_t;

typedef	union{
	u8	u8Data[2];
	s8	s8Data[2];
	u16	u16Data;
	s16	s16Data;

	struct{
		u8	b0	:1;
		u8	b1	:1;
		u8	b2	:1;
		u8	b3	:1;
		u8	b4	:1;
		u8	b5	:1;
		u8	b6	:1;
		u8	b7	:1;
		u8	b8	:1;
		u8	b9	:1;
		u8	b10	:1;
		u8	b11	:1;
		u8	b12	:1;
		u8	b13	:1;
		u8	b14	:1;
		u8	b15	:1;
	};
}bitCtrl16_t;

typedef	union{
	u8	u8Data[4];
	s8	s8Data[4];
	u16	u16Data[2];
	s16	s16Data[2];
	u32	u32Data;
	s32	s32Data;

	struct{
		u8	b0	:1;
		u8	b1	:1;
		u8	b2	:1;
		u8	b3	:1;
		u8	b4	:1;
		u8	b5	:1;
		u8	b6	:1;
		u8	b7	:1;
		u8	b8	:1;
		u8	b9	:1;
		u8	b10	:1;
		u8	b11	:1;
		u8	b12	:1;
		u8	b13	:1;
		u8	b14	:1;
		u8	b15	:1;
		u8	b16	:1;
		u8	b17	:1;
		u8	b18	:1;
		u8	b19	:1;
		u8	b20	:1;
		u8	b21	:1;
		u8	b22	:1;
		u8	b23	:1;
		u8	b24	:1;
		u8	b25	:1;
		u8	b26	:1;
		u8	b27	:1;
		u8	b28	:1;
		u8	b29	:1;
		u8	b30	:1;
		u8	b31	:1;

	};
}bitCtrl32_t;

typedef	union{
	u8		u8Data[8];
	s8		s8Data[8];
	u16		u16Data[4];
	s16		s16Data[4];
	u32		u32Data[2];
	s32		s32Data[2];

	float	fData[2];
	double	dData;
}floatCtrl_t;

enum{
	LOW = 0,
	HIGH
};

typedef	enum{
	TASK_CREATE = 0x00,
	TASK_KILL
}taskManage_t;

typedef struct{
	u32	runCnt;
	u32	errCnt;
	u32	errValue;
}checkCount_t;

#endif // !_USERDEFINE_H
