; ===========================================================================
; Defining some stuff...
	enumconf 2
	enum Null, Byte, Word, LongWord
	enumconf 1
	enum FlagWatchStart=$80, FlagExceptionFrameStart
	
	if FlagExceptionFrameStart+10 > $FF
		fatal "Too many entries before FlagExceptionFrameStart"
	endif
	
WatchListSize = $7F

; ===========================================================================
; Start of Debug "RAM"

EDRam: 												; The Mega Everdrive's rom mapper supports writing to ROM so this is going to be the ram area to avoid using extra ram
.WatchList: 	
	dc.l	(Word << 24) | (Ring_count & $00FFFFFF)
	ds.l	WatchListSize-1 									; Reserve enough space for $7F Watch Entries
.WatchCount: 	dc.b	$1
.WatchEnable:	dc.b	$0							; Only start sending the data when the PC side attaches
	even

; ===========================================================================
; Actual debugger code

EDDebugger:
	MapperEnable
	tst.b		(EDRam.WatchEnable).w
	bne.s		.ProcessWatchList
	move.b		(RegSTE+1), d0
	andi.b		#USB_WR_RDY, d0
	beq.w		EDDebuggerReturn					; USB isn't ready yet
	st.b		(EDRam.WatchEnable).w				; USB is ready so set WatchEnable flag

.ProcessWatchList:
	lea			(EDRam.WatchList).w, a0
	lea			(RegUSB), a3						; Load the USB FIFO address into a3 for S P E E D
	moveq		#0, d0								; Clear d0 so the upper 24-bits aren't garbage
	move.b		(EDRam.WatchCount).w, d0
	beq.w		EDDebuggerInput						; Skip processing watchlist if its empty
	move.b		#FlagWatchStart, (a3)				; Signal that we're ready to send some data
	move.b		d0, (a3)							; Send the current watch count
	subi.b		#1, d0								; Subtract one since we already checked if it was empty
	moveq		#0, d1								; Clear d1 so the upper 24-bits aren't garbage

.ProcessWatchEntry:
	move.b		(a0), d1							; Move the size into d1
	move.b		d1, (a3)							; Send the size of the value we're about to send
	move.l		(a0), a1							; Load the watched address into a1
	move.w		WatchListTable(pc,d1.w),d1			; Load the offset from the jump table
	jmp			WatchListTable(pc,d1.w)				; Jump
; ===========================================================================
; Jump table for the watch list

WatchListTable: 		offsetTable
Watch_Null_ptr:			offsetTableEntry.w	EDDebugger.continue	;   0	; Used to skip a deleted address
Watch_Byte_ptr:			offsetTableEntry.w	Watch_Byte      	;   2
Watch_Word_ptr:			offsetTableEntry.w	Watch_Word      	;   4
Watch_LongWord_ptr:		offsetTableEntry.w	Watch_LongWord  	;   6

; Send in little endian order
Watch_LongWord:
	move.b		$3(a1), (a3)
	move.b		$2(a1), (a3)
	
Watch_Word:
	move.b		$1(a1), (a3)
	
Watch_Byte:
	move.b		$0(a1), (a3)

EDDebugger.continue:
	adda.w		#4, a0								; Get the next entry ready
	dbf			d0, EDDebugger.ProcessWatchEntry
	;move.b		#$FF, (a3)							; Signal that we're done sending data
	
EDDebuggerInput:
	;bra.w		EDDebuggerReturn					; Skip the input part for now while fixing issues
	;move.b		(RegSTE+1), d0
	;andi.b		#USB_RD_RDY, d0
	;beq.w		EDDebuggerReturn					; USB isn't ready yet
	lea			(EDRam.WatchList).w, a0				; Reset a0 back to the beginning of the watch list
	lea			(EDRam.WatchCount).w, a1			; Load the address of the watch count into a1
	moveq		#0, d0								; Clear d0 so the upper 24-bits aren't garbage

.ProcessCommands:
	move.b		(RegSTE+1), d0
	andi.b		#USB_RD_RDY, d0
	beq.w		EDDebuggerReturn					; USB isn't ready yet
	move.b		(a3),	d0							; Get the command out of the USB FIFO (a3)
	;beq.w		EDDebuggerReturn					; Value was 0, return
	;add.w		d0,		d0							; Multiply the value by 2 for the jump table ; Less than 127 comamnds, send as pre-multiplied
	jmp			WatchCommandTable(pc,d0.w)			; Jump to the right spot for the size
; ===========================================================================
; Jump table for the watch list commands

WatchCommandTable:
.ReturnCommand:		bra.w	EDDebuggerReturn	;   0	-	No more commands
.AddWatchCommand:	bra.w	AddWatch			;   2

AddWatch:
	move.l		a0, a2							; Copy the start of the watch list into a2
	moveq		#0, d0							; Clear out d0
	
.SearchLoop:
	tst.b		(a2)							; Check if this entry is empty
	beq.s		.EmptyEntryFound				; Branch if it is
	cmpi.b		#WatchListSize, d0				; Check if we're on the last entry
	bge.s		.OutOfSpace						; Branch if we are
	lea			$4(a2), a2						; Go to the next entry
	addq		#1, d0							; Increment search count
	bra.s		.SearchLoop						; Keep searching...
	
.OutOfSpace:
	rept 4
	move.b		(a3), d0						; Eat incoming data as there is no more room
	endm
	bra.w		EDDebuggerInput.ProcessCommands
	
.EmptyEntryFound:
	move.b		(a3), $3(a2)					; Copy in the address into the watch list
	move.b		(a3), $2(a2)
	move.b		(a3), $1(a2)
	move.b		(a3), $0(a2)
	
	cmp.b		(a1), d0						; Check to see if we had to add an entry instead of overwriting one
	bgt.s		EDDebuggerInput.ProcessCommands	; Branch if overwritten
	move.b		d0, (a1)						; Copy the new list count
	bra.w		EDDebuggerInput.ProcessCommands	; Check for more commands
	
EDDebuggerReturn:
	MapperDisable
	rts
	
	if 0
ErrorHandlerReturnEnabled equ _eh_return
	else
ErrorHandlerReturnEnabled equ 0
	endif

ErrorExcept:
	__ErrorMessage "ERROR EXCEPTION", _eh_default|ErrorHandlerReturnEnabled
	MapperEnable
	move.b	#FlagExceptionFrameStart+0, d0
	bra.w	ExceptionTypeB
BusError:
	__ErrorMessage "BUS ERROR", _eh_default|_eh_address_error|ErrorHandlerReturnEnabled
	MapperEnable
	move.b	#FlagExceptionFrameStart+1, d0
	bra.w	ExceptionTypeA
AddressError:
	__ErrorMessage "ADDRESS ERROR", _eh_default|_eh_address_error|ErrorHandlerReturnEnabled
	MapperEnable
	move.b	#FlagExceptionFrameStart+2, d0
	bra.w	ExceptionTypeA
IllegalInstr:
	__ErrorMessage "ILLEGAL INSTRUCTION", _eh_default|ErrorHandlerReturnEnabled
	MapperEnable
	move.b	#FlagExceptionFrameStart+3, d0
	addq.l	#2,2(sp)
	bra.w	ExceptionTypeB
ZeroDivide:
	__ErrorMessage "ZERO DIVIDE", _eh_default|ErrorHandlerReturnEnabled
	MapperEnable
	move.b	#FlagExceptionFrameStart+4, d0
	bra.w	ExceptionTypeB
ChkInstr:
	__ErrorMessage "CHK INSTRUCTION", _eh_default|ErrorHandlerReturnEnabled
	MapperEnable
	move.b	#FlagExceptionFrameStart+5, d0
	bra.w	ExceptionTypeB
TrapvInstr:
	__ErrorMessage "TRAPV INSTRUCTION", _eh_default|ErrorHandlerReturnEnabled
	MapperEnable
	move.b	#FlagExceptionFrameStart+6, d0
	bra.w	ExceptionTypeB
PrivilegeViol:
	__ErrorMessage "PRIVILEGE VIOLATION", _eh_default|ErrorHandlerReturnEnabled
	MapperEnable
	move.b	#FlagExceptionFrameStart+7, d0
	bra.w	ExceptionTypeB
Trace:
	__ErrorMessage "TRACE", _eh_default|ErrorHandlerReturnEnabled
	MapperEnable
	move.b	#FlagExceptionFrameStart+8, d0
	bra.w	ExceptionTypeB
Line1010Emu:
	__ErrorMessage "LINE 1010 EMULATOR", _eh_default|ErrorHandlerReturnEnabled
	MapperEnable
	move.b	#FlagExceptionFrameStart+9, d0
	addq.l	#2,2(sp)
	bra.w	ExceptionTypeB
Line1111Emu:
	__ErrorMessage "LINE 1111 EMULATOR", _eh_default|ErrorHandlerReturnEnabled
	MapperEnable
	move.b	#FlagExceptionFrameStart+10, d0
	addq.l	#2,2(sp)
	bra.w	ExceptionTypeB
	
; ===========================================================================
v_regbuffer:	ds.b $40	; stores registers d0-a7 during an error event ($40 bytes)
v_spbuffer:		ds.l 1		; stores most recent sp address (4 bytes)

; ===========================================================================
; Format A Exception Stack Frames
; +0	Word
;	Bits 0-2	Function code
;	Bit 3		0:Instruction
;	Bit 4		0:Write 1:Read	
;	Bits 5-15	Unused
; +2	Longword	Access address
; +6	Word		IR
; +8	Word		SR
; +10	Longword	PC
ExceptionTypeA:
	addq.w	#2,sp
	move.l	(sp)+,(v_spbuffer).w
	addq.w	#2,sp
	movem.l	d0-a7,(v_regbuffer).w
	lea		(RegUSB), a0			; Load FIFO into a0
	bsr.w	ClearUSBCommandQueue	; Clear out the command queue to make sure we see the exception
	move.b	d0, (a0)				; Send the error flag
	lea		7(sp), a1				; Load the address of one past the end of the PC in SP
	moveq	#4-1, d0				; Load the amount of bytes to send minus 1
	bsr.w	SendUSBData				; Send the PC
	lea		(v_spbuffer+4).w, a1	; Load the pointer to what address we tried to access	
	moveq	#4-1, d0				; Load the amount of bytes to send minus 1
	bsr.w	SendUSBData				; Send the PC
	lea		(v_spbuffer).w, a1		; Load the end of v_regbuffer into a1
	moveq	#$40-1, d0				; Load the amount of bytes to send minus 1
	bsr.w	SendUSBData				; Now send all of the registers
	bra.s	ReturnFromException
; ===========================================================================
; Format B Exception Stack Frames
; +0	Word		SR
; +2	Longword	PC
; ===========================================================================
ExceptionTypeB:
	movem.l	d0-a7,(v_regbuffer).w
	lea		(RegUSB), a0			; Load FIFO into a0
	bsr.w	ClearUSBCommandQueue	; Clear out the command queue to make sure we see the exception
	move.b	d0, (a0)				; Send the error flag
	lea		7(sp), a1				; Load the address of one past the end of the PC in SP
	moveq	#4-1, d0				; Load the amount of bytes to send minus 1
	bsr.w	SendUSBData				; Send the PC
	lea		(v_spbuffer).w, a1		; Load the end of v_regbuffer into a1
	moveq	#$40-1, d0				; Load the amount of bytes to send minus 1
	bsr.w	SendUSBData				; Now send all of the registers

ReturnFromException:
	bsr.w	ErrorWaitForC
	movem.l	(v_regbuffer).w,d0-a7
	enableInterrupts
	rte	
		
ErrorWaitForC:
	bra.w	ErrorWaitForC			; Wait for input from PC. Todo: Make it actually do that
	rts	
	
ClearUSBCommandQueue:				; Writes a bunch of zeros to the buffer so the PC will see this exception
	moveq	#WatchListSize, d1
.loop:
	rept 4
	move.b	#0, (a0)
	endm
	dbf d1,.loop
.waitForQueue:
	
	rts
	
; ===========================================================================
; Copy data to USB
; ===========================================================================
; PARAMETERS:
;	a0.l - FIFO USB Register
;	a1.l - Pointer to one byte past the end of the data to copy
;	d0.b - Number of bytes to copy minus 1
; RETURNS:
;	a1.l - Pointer to the start of the data
; ===========================================================================
SendUSBData:
	move.b	-(a1), (a0)
	dbf		d0,SendUSBData
	rts
