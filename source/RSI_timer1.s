@;=                                                          	     	=
@;=== RSI_timer1.s: rutinas para escalar los elementos (sprites)	  ===
@;=                                                           	    	=
@;=== Programador tarea 2F: gerard.casass@estudiants.urv.cat		  ===
@;=                                                       	        	=

.include "../include/candy2_incl.i"


@;-- .data. variables (globales) inicializadas ---
.data
		.align 2
		.global timer1_on
	timer1_on:	.hword	0 			@;1 -> timer1 en marcha, 0 -> apagado
	divFreq1: 	.hword	-5754		@;divisor de frecuencia para timer 1


@;-- .bss. variables (globales) no inicializadas ---
.bss
		.align 2
	escSen: .space	2				@;sentido de escalado (0-> dec, 1-> inc)
	escFac: .space	2				@;Factor actual de escalado
	escNum: .space	2				@;n�mero de variaciones del factor


@;-- .text. c�digo de las rutinas ---
.text	
		.align 2
		.arm


@;TAREA 2Fb;
@;activa_timer1(init); rutina para activar el timer 1, inicializando el sentido
@;	de escalado seg�n el par�metro init.
@;	Par�metros:
@;		R0 = init;  valor a trasladar a la variable 'escSen' (0/1)
	.global activa_timer1
activa_timer1:
		push {r0-r2, lr}

		cmp r0, #0
		movhi r0, #1				@; if init >= 1 => init = 1
		movlt r0, #0				@; if init < 0 => init = 0
		
		ldr r1, =escSen
		strh r0, [r1]				@; escSen = init

		bhi .Lend_decrement_cicle	@; if inti > 0
		.Ldecrement_cicle:
			mov r0, #1
			mov r0, r0, lsl #8
			ldr r1, =escFac			@; escFac = 1,0
			strh r0, [r1]

			mov r1, r0
			mov r2, r0
			mov r0, #0				@; modify group 0, PA & PD 
			bl SPR_fijarEscalado
		.Lend_decrement_cicle:

		mov r0, #0
		ldr r1, =escNum				@; escNum = 0
		strh r0, [r1]

		mov r0, #1					@; timer1_on = 1
		ldr r1, =timer1_on
		strh r0, [r1]

		ldr r0, =divFreq1			@; r0 = divFreq1
		ldsh r0, [r0]

		ldr r1, =TIMER1_DATA
		mov r0, r0, lsl #16
        mov r0, r0, lsr #16		@; TIMER1_DATA = divFreq1
        orr r0, #0xC10000		@; TIMER1_CR = F/64 | irq enabled | start
		str r0, [r1]		

		pop {r0-r2, pc}


@;TAREA 2Fc;
@;desactiva_timer1(); rutina para desactivar el timer 1.
	.global desactiva_timer1
desactiva_timer1:
		push {r0-r1, lr}

		ldr r0, =TIMER1_CR
		mov r1, #0
		strh r1, [r0]		@; disable timer

		ldr r0, =timer1_on
		strh r1, [r0]		@; timer1_on = 0
		
		pop {r0-r1, pc}



@;TAREA 2Fd;
@;rsi_timer1(); rutina de Servicio de Interrupciones del timer 1: incrementa el
@;	n�mero de escalados y, si es inferior a 32, actualiza factor de escalado
@;	actual seg�n el c�digo de la variable 'escSen'. Cuando se llega al m�ximo
@;	se desactivar� el timer1.
	.global rsi_timer1
rsi_timer1:
		push {r0-r2, lr}
		
		ldr r0, =escNum		@; escNum++
		ldrh r1, [r0]
		add r1, #1
		strh r1, [r0]

		cmp r1, #TICS			@; if(escNum >= 32) desactivar_timer1() else ...
		blhs desactiva_timer1
		bhs .Lend_rsi_timer1

		mov r2, #5				@; r0 = 1/32 = 0.03125 => increment and decrement diferencial for tic

		ldr r0, =escSen
		ldrh r1, [r0]
		cmp r1, #0

		ldr r0, =escFac
		ldrh r1, [r0]
		subne r1, r2
		addeq r1, r2
		strh r1, [r0]		

		mov r0, #0
		mov r2, r1
		bl SPR_fijarEscalado

		mov r1, #1
		ldr r0, =update_spr
		strh r1, [r0]			@; update_spr = 1

		.Lend_rsi_timer1:
		
		pop {r0-r2, pc}

.end
