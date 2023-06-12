	include "s2.options.asm"					; Options from the main file so the macros work
	include "../s2.macrosetup.asm"
	include "../s2.macros.asm"
	include "s2.constants.asm"					; SubCPU Specific variables
	include	"cdbios.asm"						; SubCPU BIOS Library

	phase $6000 								; pretend we're at address $6000, where the SubCPU program will live

Header:
	dc.b	"MAIN       "						; module name
	dc.b	$0									; flag
	dc.w	$0100								; version
	dc.w	$0									; type
	dc.l	$0									; ptr. next module 
	dc.l	$0									; module size 
	dc.l	JumpTable-Header					; start address 
	dc.l	$0									; work RAM size - Unused

JumpTable:
	dc.w	Init-JumpTable						; initialization routine
	dc.w	Main-JumpTable						; main routine
	dc.w	L2Int-JumpTable						; level 2 interrupt routine
	dc.w	UserDefined-JumpTable				; user defined routine (cannot be called from the system) 
	dc.w	$0									; end mark (zero) 
	even


Init:
	spinWait	cmpi.b, #1, (CdCommMainflag)	; Wait for the Main CPU to finish getting initialized

    move.b		#2,(CdCommSubflag)				; Tell the Main CPU we got the memo

	spinWaitTst.b	(CdCommMainflag)			; Is the Main CPU ready to send commands?

	move.b    #1,(CdCommSubflag)				; Mark as ready to retrieve commands

	move.w		#$02, (RAM.CDTrack)
	rts

Main:

.loop
	lea		(InitParams), 	a0
	BIOS_DRVINIT

    BIOS_CDBSTAT								; Check the BIOS
    move.w    (a0),d0
    andi.w    #$F000,d0							; Is it ready?
    bne.s    .loop								; If not, wait


	lea		(RAM.CDTrack), a0
	BIOS_MSCPLAYR
	bra.w *
	rts

L2Int:
	rts

UserDefined:
	rts

InitParams:
	dc.b	$01, $FF
