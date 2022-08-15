; ---------------------------------------------------------------------------
; SSF2 Mapper stuff
MapperBank1 	= 	$A130F3	; bank for $080000-$0FFFFF
MapperBank2 	= 	$A130F5	; bank for $100000-$17FFFF
MapperBank3 	= 	$A130F7	; bank for $180000-$1FFFFF
MapperBank4 	= 	$A130F9	; bank for $200000-$27FFFF
MapperBank5 	= 	$A130FB	; bank for $280000-$2FFFFF
MapperBank6 	= 	$A130FD	; bank for $300000-$37FFFF
MapperBank7 	= 	$A130FF	; bank for $380000-$3FFFFF

MapPageToBank macro page,bank
	move.b	#page,	(bank)
	endm

InitSSF2:
	MapPageToBank  1, MapperBank1
	MapPageToBank  2, MapperBank2
	MapPageToBank  3, MapperBank3
	MapPageToBank  4, MapperBank4
	MapPageToBank  5, MapperBank5
	MapPageToBank  6, MapperBank6
	MapPageToBank  7, MapperBank7
	rts
	