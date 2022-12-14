; ===========================================================================
; Defining some stuff...
	enumconf 2
	enum Null, Byte, Word, LongWord
	enumconf 1										; Probably not needed but just being safe
	
WatchEntry	STRUCT DOTS
	Size:		ds.b	$1
				ds.w	$0							; Wasting a byte here but that's only to maintain alignment
	Address:	ds.l	$1
WatchEntry	ENDSTRUCT

; ===========================================================================
; Start of Debug "RAM"

EDRam: 												; The Mega Everdrive's rom mapper supports writing to ROM so this is going to be the ram area to avoid using extra ram
;.WatchList: 	dc.b	Word
;				dc.b	$0
;				dc.l	Ring_count
.WatchList: 	WatchEntry [$1F] 					; Reserve enough space for $1F Watch Entries
.WatchCount: 	dc.b	$0
.WatchEnable:	dc.b	$0							; Only start sending the data when the PC side attaches
	even

; ===========================================================================
; Actual debugger code

EDDebugger:
	MapperEnable
	moveq		#0, d0
	tst.b		(EDRam.WatchEnable).w
	bne.s		.ProcessWatchList
	move.b		(RegSTE+1), d0
	andi.b		#USB_RD_RDY, d0
	beq.w		EDDebuggerReturn					; USB isn't ready yet
	st.b		(EDRam.WatchEnable).w				; USB is ready so set WatchEnable flag

.ProcessWatchList:
	lea			(EDRam.WatchList).w, a0
	lea			(RegUSB), a3						; Load the USB FIFO address into a3 for S P E E D
	move.b		(EDRam.WatchCount).w, d0
	beq.w		EDDebuggerInput						; Skip processing watchlist if its empty
	move.b		#$FF, (a3)							; Signal that we're ready to send some data
	move.b		d0, (a3)							; Send the current watch count
	subi.b		#1, d0								; Subtract one since we already checked if it was empty

.ProcessWatchEntry:
	moveq		#0, d1
	move.b		WatchEntry.Size(a0), d1				; Move the size to d1
	move.b		d1, (a3)							; Send the size of the value we're about to send
	movea.l		WatchEntry.Address(a0), a1			; Load the watched address from the entry in a0 to a1
	move.w		WatchListTable(pc,d1.w),d1			; ???
	jmp			WatchListTable(pc,d1.w)				; Jump to the right spot for the size
; ===========================================================================
; Jump table for the watch list

WatchListTable: 		offsetTable
Watch_Null_ptr:			offsetTableEntry.w	EDDebugger.continue	;   0	; This shouldn't happen unless the Desktop side fucked up
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
	lea			WatchEntry.len(a0), a0				; Get the next entry ready
	
	dbf			d0, EDDebugger.ProcessWatchEntry
	move.b		#$FF, (a3)							; Signal that we're done sending data
	
EDDebuggerInput:
	move.b		(RegSTE+1), d0
	andi.b		#USB_RD_RDY, d0
	beq.w		EDDebuggerReturn					; USB isn't ready yet
	lea			(EDRam.WatchList).w, a0				; Reset a0 back to the beginning of the watch list
	move.b		(EDRam.WatchCount).w, d0			; Move the current watch count into d0 so we can calculate the index
	mulu.w		
.ProcessCommands:
	move.w		(a3),	d0							; Get the command out of the USB FIFO (a3)
	beq.w		EDDebuggerReturn					; Value was 0, return
	add.w		d0,		d0							; Multiply the value by 2 for the jump table
	move.w		WatchCommandTable(pc,d0.w),d0		; ???
	jmp			WatchCommandTable(pc,d0.w)			; Jump to the right spot for the size
; ===========================================================================
; Jump table for the watch list commands

WatchCommandTable: 		offsetTable
AddWatchReturn_ptr:		offsetTableEntry.w	EDDebuggerReturn	;   0	-	No more commands
AddWatchByte_ptr:		offsetTableEntry.w	AddWatchByte      	;   2
AddWatchWord_ptr:		offsetTableEntry.w	AddWatchWord      	;   4
AddWatchLong_ptr:		offsetTableEntry.w	AddWatchLong  		;   6

; Recieve in little endian order
AddWatchLong:
	move.b		

AddWatchWord:

AddWatchByte:
	
EDDebuggerReturn:
	MapperDisable
	rts
