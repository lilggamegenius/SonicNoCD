; ---------------------------------------------------------------------------
; SSF2 Mapper stuff
MapperBank0 	= 	$A130F1	; bank for $000000-$07FFFF on Mega EverDrive only
MapperBank1 	= 	$A130F3	; bank for $080000-$0FFFFF
MapperBank2 	= 	$A130F5	; bank for $100000-$17FFFF
MapperBank3 	= 	$A130F7	; bank for $180000-$1FFFFF
MapperBank4 	= 	$A130F9	; bank for $200000-$27FFFF
MapperBank5 	= 	$A130FB	; bank for $280000-$2FFFFF
MapperBank6 	= 	$A130FD	; bank for $300000-$37FFFF
MapperBank7 	= 	$A130FF	; bank for $380000-$3FFFFF

	if EDDebug
SsfCtrlP		=	$80		; register accesss protection bit. should be set, otherwise register will ignore any attempts to write
SsfCtrlX		=	$40		; 32x mode
SsfCtrlW		=	$20		; ROM memory write protection
SsfCtrlL		=	$10		; led

USB_WR_RDY		=	$2		; USB Ready to send data bit
USB_RD_RDY		=	$4		; USB Ready to recieve data bit

SsfReg			=	$A13000	; 
RegSPI			=	SsfReg+$E0 ; SD io
RegUSB			=	SsfReg+$E3 ; usb io
RegSTE			=	SsfReg+$E4 ; status 
RegCFG			=	SsfReg+$E6 ; IO config
RegSSFCtrl		=	SsfReg+$F0

MapperEnable macro
	move.b		#SsfCtrlP|SsfCtrlW|SsfCtrlL, (RegSSFCtrl)
	endm

MapperDisable macro
	move.b		#SsfCtrlP, (RegSSFCtrl)
	endm

	endif

MapPageToBank macro page,bank
	move.b	#page,	(bank)
	endm

InitSSF2:
	if EDDebug
	MapPageToBank  0, MapperBank0
	endif
	MapPageToBank  1, MapperBank1
	MapPageToBank  2, MapperBank2
	MapPageToBank  3, MapperBank3
	MapPageToBank  4, MapperBank4
	MapPageToBank  5, MapperBank5
	MapPageToBank  6, MapperBank6
	MapPageToBank  7, MapperBank7
	rts
	