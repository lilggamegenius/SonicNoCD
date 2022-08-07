; >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; ASSEMBLY OPTIONS:
; These are taken from the main asm so the macro includes work
;
gameRevision = 2
;	| If 0, a REV00 ROM is built
;	| If 1, a REV01 ROM is built, which contains some fixes
;	| If 2, a (probable) REV02 ROM is built, which contains even more fixes
padToPowerOfTwo = 0
;	| If 1, pads the end of the ROM to the next power of two bytes (for real hardware)
;
fixBugs = 1
;	| If 1, enables all bug-fixes
;	| See also the 'FixDriverBugs' flag in 's2.sounddriver.asm'
allOptimizations = 1
;	| If 1, enables all optimizations
;
skipChecksumCheck = 1
;	| If 1, disables the slow bootup checksum calculation
;
zeroOffsetOptimization = 0|allOptimizations
;	| If 1, makes a handful of zero-offset instructions smaller
;
removeJmpTos = 0|(gameRevision=2)|allOptimizations
;	| If 1, many unnecessary JmpTos are removed, improving performance
;
addsubOptimize = 0|(gameRevision=2)|allOptimizations
;	| If 1, some add/sub instructions are optimized to addq/subq
;
relativeLea = 0|(gameRevision<>2)|allOptimizations
;	| If 1, makes some instructions use pc-relative addressing, instead of absolute long

	include "../s2.macrosetup.asm"
	include "../s2.macros.asm"
	include "s2.constants.asm"
	include	"cdbios.asm"
	
	phase $6000 ; pretend we're at address $6000, where the SubCPU program will live

Header:
	dc.b	"MAIN       ",0						; module name
	dc.b	$0									; flag
	dc.w	$0100								; version
	dc.w	$0									; type
	dc.l	$0									; ptr. next module 
	dc.l	ModuleEnd-Init						; module size 
	dc.l	JumpTable-Header					; start address 
	dc.l	RAM_End-RAM_Start					; work RAM size
	
JumpTable:
	dc.w	Init-JumpTable						; initialization routine
	dc.w	Main-JumpTable						; main routine
	dc.w	L2Int-JumpTable						; level 2 interrupt routine
	dc.w	UserDefined-JumpTable				; user defined routine (cannot be called from the system) 
	dc.w	$0									; end mark (zero) 
	even

	
Init:
	lea		(InitParams), 	a0
	BIOS_DRVINIT
	lea		(InitialTrack), a0
	BIOS_MSCPLAYR
	rts
	
Main:
	rts
	
L2Int:
	rte
	
UserDefined:
	rts
	
InitParams:
	dc.b	$01	; Track # to read TOC from (normally $01)
	dc.b	$FF	; Last track # ($FF = read all tracks)
	
InitialTrack:
	dc.w	$02	
	
ModuleEnd: