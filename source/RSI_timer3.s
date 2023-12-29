@;=                                                          	     	=
@;=== RSI_timer3.s: rutinas para desplazar el fondo 3 (imagen bitmap) ===
@;=                                                           	    	=
@;=== Programador tarea 2H: gerard.casass@estudiants.urv.cat		  ===
@;=                                                       	        	=

.include "../include/candy2_incl.i"


@;-- .data. variables (globales) inicializadas ---
.data
		.align 2
		.global update_bg3
	update_bg3:	.hword	0			@;1 -> actualizar fondo 3
		.global timer3_on
	timer3_on:	.hword	0 			@;1 -> timer3 en marcha, 0 -> apagado
		.global offsetBG3X
	offsetBG3X: .hword	0			@;desplazamiento vertical fondo 3
	sentidBG3X:	.hword	0			@;sentido desplazamiento (0-> inc / 1-> dec)
	divFreq3: 	.hword	-13091		@;divisor de frecuencia para timer 3
	


@;-- .text. c�digo de las rutinas ---
.text	
		.align 2
		.arm


@;TAREA 2Hb;
@;activa_timer3(); rutina para activar el timer 3.
	.global activa_timer3
activa_timer3:
		push {r0-r1, lr}
		
		ldr r0, =divFreq3
		ldsh r0, [r0]

		ldr r1, =TIMER3_DATA
		mov r0, r0, lsl #16
        mov r0, r0, lsr #16
        orr r0, #0xC20000
		str r0, [r1]		@; TIMER3_DATA = divFreq3
							@; TIMER3_CR = F/256 | irq enabled | start

		ldr r1, =timer3_on
		mov r0, #1
		strh r0, [r1]

		pop {r0-r1, pc}

@;TAREA 2Hc;
@;desactiva_timer3(); rutina para desactivar el timer 3.
	.global desactiva_timer3
desactiva_timer3:
		push {r0-r1, lr}

		ldr r0, =TIMER3_CR
		mov r1, #0
		strh r1, [r0]		@; disable timer

		ldr r0, =timer3_on
		strh r1, [r0]		@; timer3_on = 0
		
		pop {r0-r1, pc}



@;TAREA 2Hd;
@;rsi_timer3(); rutina de Servicio de Interrupciones del timer 3: incrementa o
@;	decrementa el desplazamiento X del fondo 3 (sobre la variable global
@;	'offsetBG3X'), seg�n el sentido de desplazamiento actual; cuando el
@;	desplazamiento llega a su l�mite, se cambia el sentido; adem�s, se avisa
@;	a la RSI de retroceso vertical para que realice la actualizaci�n del
@;	registro de control del fondo correspondiente.
	.global rsi_timer3
rsi_timer3:
		push {r0-r3, lr}

		ldr r1, =offsetBG3X
		ldrh r2, [r1]

		ldr r3, =sentidBG3X
		ldrh r0, [r3]

		cmp r0, #0
		addeq r2, #1
		subne r2, #1

		strh r2, [r1] 							@; 	offsetBG3X = ++ or --				

		cmp r2, #320
		beq .Lrsi3_change_bg_direction

		cmp r2, #0
		beq .Lrsi3_change_bg_direction
		
		b .Lend_rsi3_change_bg_direction
		.Lrsi3_change_bg_direction:
			and r0, #0x01
			eor r0, #0x01
			strh r0, [r3]
		.Lend_rsi3_change_bg_direction:

		mov r1, #1
		ldr r0, =update_bg3
		strh r1, [r0]						@; update_bg3 = 1

		pop {r0-r3, pc}



.end
