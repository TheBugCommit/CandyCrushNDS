@;=                                                          	     	=
@;=== RSI_timer2.s: rutinas para animar las gelatinas (metabaldosas)  ===
@;=                                                           	    	=
@;=== Programador tarea 2G: gerard.casass@estudiants.urv.cat		  ===
@;=                                                       	        	=

.include "../include/candy2_incl.i"


@;-- .data. variables (globales) inicializadas ---
.data
		.align 2
		.global update_gel
	update_gel:	.hword	0			@;1 -> actualizar gelatinas
		.global timer2_on
	timer2_on:	.hword	0 			@;1 -> timer2 en marcha, 0 -> apagado
	divFreq2: 	.hword	-13091		@;divisor de frecuencia para timer 2



@;-- .text. c�digo de las rutinas ---
.text	
		.align 2
		.arm


@;TAREA 2Gb;
@;activa_timer2(); rutina para activar el timer 2.
	.global activa_timer2
activa_timer2:
		push {r0-r1, lr}
		
		ldr r0, =divFreq2
		ldsh r0, [r0]

		ldr r1, =TIMER2_DATA
		mov r0, r0, lsl #16
        mov r0, r0, lsr #16
        orr r0, #0xC20000
		str r0, [r1]		@; TIMER2_DATA = divFreq2
							@; TIMER2_CR = F/256 | irq enabled | start

		ldr r1, =timer2_on
		mov r0, #1
		strh r0, [r1]

		pop {r0-r1, pc}


@;TAREA 2Gc;
@;desactiva_timer2(); rutina para desactivar el timer 2.
	.global desactiva_timer2
desactiva_timer2:
		push {r0-r1, lr}

		ldr r0, =TIMER2_CR
		mov r1, #0
		strh r1, [r0]		@; disable timer

		ldr r0, =timer2_on
		strh r1, [r0]		@; timer0_on = 0
		
		pop {r0-r1, pc}



@;TAREA 2Gd;
@;rsi_timer2(); rutina de Servicio de Interrupciones del timer 2: recorre todas
@;	las posiciones de la matriz mat_gel y, en el caso que el c�digo de
@;	activaci�n (ii) sea mayor o igual a 1, decrementa dicho c�digo en una unidad
@;	y, en el caso que alguna llegue a 0, incrementa su c�digo de metabaldosa y
@;	activa una variable global update_gel para que la RSI de VBlank actualize
@;	la visualizaci�n de dicha metabaldosa.
	.global rsi_timer2
rsi_timer2:
		push {r0-r2, lr}
		
		ldr r0, =mat_gel						@; @mat_gel
		mov r1, #0								@; i = 0;
		.Lfor_rsi2_mat_gel:
			ldsb r2, [r0, #GEL_II]
			cmp r2, #0	
			blt .Lfor_rsi2_mat_gel_cont
			beq .Lrsi2_change_im

			sub r2, #1							@; mat_gel[i][j].ii--;
			strb r2, [r0, #GEL_II]
			cmp r2, #0	
			bne .Lfor_rsi2_mat_gel_cont			

			.Lrsi2_change_im:					@; if(mat_gel[i][j].ii == 0)
			ldrb r2, [r0, #GEL_IM]
			tst r2, #0x08
			add r2, #1
			bne .Lrsi2_double_jelly

			.Lrsi2_simple_jelly:
				cmp r2, #7
				movhi r2, #0
				b .Lend_rsi2_double_jelly
			.Lrsi2_double_jelly:
				cmp r2, #15
				movhi r2, #8
			.Lend_rsi2_double_jelly:

			strb r2, [r0, #GEL_IM]		@; mat_gel[i][j].im++ o mat_gel[i][j].im = 8 o mat_gel[i][j].im = 0 
			.Lfor_rsi2_mat_gel_cont:

			add r0, #GEL_TAM			@; @mat_gel + GEL_TAM
			add r1, #1					@; i++
			cmp r1, #ROWS*COLUMNS		@; i < ROWS*COLUMNS
			blo .Lfor_rsi2_mat_gel

		mov r0, #1
		ldr r1, =update_gel
		strh r0, [r1]				@; update_gel = 1

		pop {r0-r2, pc}



.end
