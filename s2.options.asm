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
;
useFullWaterTables = 1
;	| If 1, zone offset tables for water levels cover all level slots instead of only slots 8-$F
;	| Set to 1 if you've shifted level IDs around or you want water in levels with a level slot below 8