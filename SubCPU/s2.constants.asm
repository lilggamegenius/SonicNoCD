; >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; Equates section - SubCPU - Names for variables specifically for the MCD CPU
CdCommMain1	=  $FF8010  ; Main-CPU to Sub-CPU port #1
CdCommMain2	=  $FF8012  ; Main-CPU to Sub-CPU port #2
CdCommMain3	=  $FF8014  ; Main-CPU to Sub-CPU port #3
CdCommMain4	=  $FF8016  ; Main-CPU to Sub-CPU port #4
CdCommMain5	=  $FF8018  ; Main-CPU to Sub-CPU port #5
CdCommMain6	=  $FF801A  ; Main-CPU to Sub-CPU port #6
CdCommMain7	=  $FF801C  ; Main-CPU to Sub-CPU port #7
CdCommMain8	=  $FF801E  ; Main-CPU to Sub-CPU port #8

CdCommSub1	=  $FF8020  ; Sub-CPU to Main-CPU port #1
CdCommSub2	=  $FF8022  ; Sub-CPU to Main-CPU port #2
CdCommSub3	=  $FF8024  ; Sub-CPU to Main-CPU port #3
CdCommSub4	=  $FF8026  ; Sub-CPU to Main-CPU port #4
CdCommSub5	=  $FF8028  ; Sub-CPU to Main-CPU port #5
CdCommSub6	=  $FF802A  ; Sub-CPU to Main-CPU port #6
CdCommSub7	=  $FF802C  ; Sub-CPU to Main-CPU port #7
CdCommSub8	=  $FF802E  ; Sub-CPU to Main-CPU port #8

LED_NONE = %00
LED_GREEN = %10  ; READY
LED_RED = %01  ; ACCESS
LED_BOTH = %11  ; READY+ACCESS


	phase	ramaddr($FF0C0000)	; Pretend we're in the RAM
RAM_Start:
Misc_Stuff:
	ds.b	$50
RAM_End:

	dephase
	
	!org	0	; Reset the program counter