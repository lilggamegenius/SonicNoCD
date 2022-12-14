; >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; Equates section - SubCPU - Names for variables specifically for the MCD CPU
CdRegisters 	=	$FF8000

CdVersionNo		=	CdRegisters+$00
CdResetLed		=	CdRegisters+$01
CdMemoryMode	=	CdRegisters+$02
CdWriteProtect	=	CdRegisters+$03

CdStopWatch		=	CdRegisters+$0C
CdCommMainflag	=	CdRegisters+$0E
CdCommSubflag	=	CdRegisters+$0F

CdCommMain1		=	CdRegisters+$10  ; Main-CPU to Sub-CPU port #1
CdCommMain2		=	CdRegisters+$12  ; Main-CPU to Sub-CPU port #2
CdCommMain3		=	CdRegisters+$14  ; Main-CPU to Sub-CPU port #3
CdCommMain4		=	CdRegisters+$16  ; Main-CPU to Sub-CPU port #4
CdCommMain5		=	CdRegisters+$18  ; Main-CPU to Sub-CPU port #5
CdCommMain6		=	CdRegisters+$1A  ; Main-CPU to Sub-CPU port #6
CdCommMain7		=	CdRegisters+$1C  ; Main-CPU to Sub-CPU port #7
CdCommMain8		=	CdRegisters+$1E  ; Main-CPU to Sub-CPU port #8

CdCommSub1		=	CdRegisters+$20  ; Sub-CPU to Main-CPU port #1
CdCommSub2		=	CdRegisters+$22  ; Sub-CPU to Main-CPU port #2
CdCommSub3		=	CdRegisters+$24  ; Sub-CPU to Main-CPU port #3
CdCommSub4		=	CdRegisters+$26  ; Sub-CPU to Main-CPU port #4
CdCommSub5		=	CdRegisters+$28  ; Sub-CPU to Main-CPU port #5
CdCommSub6		=	CdRegisters+$2A  ; Sub-CPU to Main-CPU port #6
CdCommSub7		=	CdRegisters+$2C  ; Sub-CPU to Main-CPU port #7
CdCommSub8		=	CdRegisters+$2E  ; Sub-CPU to Main-CPU port #8



	phase	ramaddr($FF0C0000)	; Pretend we're in the RAM
RAM:

.CDTrack:		ds.w	$01	
	
RAM_End:

	dephase
	
	!org	0	; Reset the program counter