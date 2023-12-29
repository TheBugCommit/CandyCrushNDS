@;=== candy2_incl.i: definiciones comunes para ficheros en ensamblador  ===
@;===				(versi�n 2)											===

.include "../include/candy1_incl.i"

@; Pixeles por casilla del tablero de juego
MTWIDTH = 256 / COLUMNS				@; num. p�xeles de ancho (e.g. 32)
MTHEIGHT = 192 / ROWS				@; num. p�xeles de alto (e.g. 32)

@; Dimensiones de las metabaldosas
MTROWS = MTHEIGHT / 8				@; num. filas metabaldosa (e.g. 4)
MTCOLS = MTWIDTH / 8				@; num. columnas metabaldosa (e.g. 4)
MTOTAL = MTROWS * MTCOLS			@; num. total de baldosas simples

@; Timers
TIMER0_DATA = 0x04000100
TIMER1_DATA = 0x04000104
TIMER2_DATA = 0x04000108
TIMER3_DATA = 0x0400010C
TIMER0_CR = 0x04000102
TIMER1_CR = 0x04000106
TIMER2_CR = 0x0400010A
TIMER3_CR = 0x0400010E

@;MEM ADDRESS
OAM = 0x07000000

REG_BG3X = 0x04000038

@; Estructura 'elemento' (ver fichero 'candy2_incl.h")
ELE_II = 0
ELE_PX = 2
ELE_PY = 4
ELE_VX = 6
ELE_VY = 8
ELE_TAM = 10


@; Estructura 'gelatina' (ver fichero 'candy2_incl.h")
GEL_II = 0
GEL_IM = 1
GEL_TAM = 2

TICS = 32
