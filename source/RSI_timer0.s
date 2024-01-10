@;=                                                          	     	=
@;=== RSI_timer0.s: rutinas para mover los elementos (sprites)		  ===
@;=                                                           	    	=
@;=== Programador tarea 2E: gerard.casass@estudiants.urv.cat		  ===
@;=== Programador tarea 2G: gerard.casass@estudiants.urv.cat		  ===
@;=== Programador tarea 2H: gerard.casass@estudiants.urv.cat		  ===
@;=                                                       	        	=

.include "../include/candy2_incl.i"


@;-- .data. variables (globales) inicializadas ---
.data
		.align 2
		.global update_spr
	update_spr:	.hword	0			@; 1 -> actualizar sprites
		.global timer0_on
	timer0_on:	.hword	0 			@; 1 -> timer0 en marcha, 0 -> apagado
	divFreq0:   .hword	-8182		@; divisor de frecuencia inicial para timer 0 -((F/64)/64Hz) = -8182 
									@  divisor de frecuencia se decrementa hasta -((F/64)/120Hz) = -4363 


@;-- .bss. variables (globales) no inicializadas ---
.bss
		.align 2
	divF0: .space	2				@;divisor de frecuencia actual


@;-- .text. c�digo de las rutinas ---
.text	
		.align 2
		.arm

@;TAREAS 2Ea,2Ga,2Ha;
@;rsi_vblank(void); Rutina de Servicio de Interrupciones del retrazado vertical;
@;Tareas 2E,2F: actualiza la posici�n y forma de todos los sprites
@;Tarea 2G: actualiza las metabaldosas de todas las gelatinas
@;Tarea 2H: actualiza el desplazamiento del fondo 3
	.global rsi_vblank
rsi_vblank:
		push {r0-r6, lr}
		
@;Tareas 2Ea
		ldr r3, =update_spr
		ldrh r2, [r3]

		cmp r2, #0
		beq .Lno_spr_update
		
		ldr r0, =OAM
		ldr r1, =n_sprites
		ldr r1, [r1]
		bl SPR_actualizarSprites

		mov r2, #0			@; update_spr = 0
		strh r2, [r3]

		.Lno_spr_update:
@;Tarea 2Ga
		ldr r1, =update_gel
		ldrh r0, [r1]
		cmp r0, #0
		beq .Lno_update_gel
		
		mov r0, #0
		strh r0, [r1]			@; update_gel = 0 

		ldr r0, =0x06000000
		ldr r4, =mat_gel
		mov r6, #0				@; i = 0;
		.Lfor_mat_gel_rows:
			mov r5, #0			@; j = 0;
			.Lfor_mat_gel_cols:
				ldsb r1, [r4, #GEL_II]
				cmp r1, #0
				bne .Lfor_mat_gel_cols_cont

				mov r1, r6
				mov r2, r5
				ldrb r3, [r4, #GEL_IM]
				bl fija_metabaldosa			@; fija_metabaldosa(0x06000000, i, j, mat_gel[i][j].im)

				mov r1, #10
				strb r1, [r4, #GEL_II]

				.Lfor_mat_gel_cols_cont:

				add r4, #GEL_TAM	@; increment offset
				add r5, #1
				cmp r5, #COLUMNS
				blo .Lfor_mat_gel_cols
			.Lend_for_mat_gel_cols:

			add r6, #1
			cmp r6, #ROWS
			blo .Lfor_mat_gel_rows
		.Lend_for_mat_gel_rows:
		
		.Lno_update_gel:
@;Tarea 2Ha
		ldr r0, =update_bg3
		ldrh r1, [r0]
		cmp r1, #0
		beq .Lno_update_bg3

		ldr r1, =offsetBG3X
		ldrh r2, [r1]

		mov r2, r2, lsl #8			@; offsetBG3X << 8 => 0:20:8
		ldr r1, =REG_BG3X
		str r2, [r1]				@; REG_BG3X = offsetBG3X 

		mov r1, #0
		strh r1, [r0]				@; update_bg3 = 0

		.Lno_update_bg3:
		pop {r0-r6, pc}




@;TAREA 2Eb;
@;activa_timer0(init); rutina para activar el timer 0, inicializando o no el
@;	divisor de frecuencia seg�n el par�metro init.
@;	Par�metros:
@;		R0 = init; si 1, restablecer divisor de frecuencia original divFreq0
	.global activa_timer0
activa_timer0:
		push {r0-r1, lr}
		
		
		cmp r0, #0
		beq .Ltimer0_continue_same_freq

		ldr r0, =divFreq0
		ldsh r0, [r0]

		ldr r1, =divF0
		strh r0, [r1]		@; divF0 = divFreq0

		ldr r1, =TIMER0_DATA
		strh r0, [r1]		@; TIMER0_DATA = divFreq0

		.Ltimer0_continue_same_freq:
			ldr r1, =TIMER0_CR
			mov r0, #0xC1
			strh r0, [r1]		@; TIMER0_CR = F/64 | irq enabled | start

		ldr r1, =timer0_on
		mov r0, #1
		strh r0, [r1]

		pop {r0-r1, pc}


@;TAREA 2Ec;
@;desactiva_timer0(); rutina para desactivar el timer 0.
	.global desactiva_timer0
desactiva_timer0:
		push {r0-r1, lr}

		ldr r0, =TIMER0_CR
		mov r1, #0
		strh r1, [r0]		@; disable timer

		ldr r0, =timer0_on
		strh r1, [r0]		@; timer0_on = 0
		
		pop {r0-r1, pc}



@;TAREA 2Ed;
@;rsi_timer0(); rutina de Servicio de Interrupciones del timer 0: recorre todas
@;	las posiciones del vector vect_elem y, en el caso que el c�digo de
@;	activaci�n (ii) sea mayor o igual a 0, decrementa dicho c�digo y actualiza
@;	la posici�n del elemento (px, py) de acuerdo con su velocidad (vx,vy),
@;	adem�s de mover el sprite correspondiente a las nuevas coordenadas.
@;	Si no se ha movido ning�n elemento, se desactivar� el timer 0. En caso
@;	contrario, el valor del divisor de frecuencia se reducir� para simular
@;  el efecto de aceleraci�n (con un l�mite).
	.global rsi_timer0
rsi_timer0:
		push {r0-r4, lr}
		
		ldr r3, =n_sprites
		ldr r3, [r3]				@; r3 = n_sprites

		ldr r2, =vect_elem			@; r2 = @vect_elem

		mov r4, #0					@; element_moved = false

		mov r1, #0					@; i = 0
		.Lfor_sprites:
			cmp r1, r3				@; for(i < n_sprites)
			bhs .Lend_for_sprites

			mov r0, r2		 
			bl update_elment  		@; update_element(@vect_elem[i], i)
			
			@; element_moved = !element_moved && update_element(@vect_elem[i], i)
			.Lif_elem_moved:
				cmp r4, #0		
				bne .Lend_if_elem_moved

				cmp r0, #0
				beq .Lend_if_elem_moved

				mov r4, r0
			.Lend_if_elem_moved:

			add r2, #ELE_TAM		@; @vect_elem += ELE_TAM;
			add r1, #1				@; i++
			b .Lfor_sprites
		.Lend_for_sprites:

		cmp r4, #0				
		beq .Lelement_not_moved   	@; if(element_moved) 

		ldr r1, =update_spr
		mov r0, #1
		strh r0, [r1]				@; update_spr = 1

		ldr r1, =divF0
		ldsh r0, [r1]
		adds r0, #120				@; decrement freq
		ldr r2, =0xFFFFEEF5         		
		cmp r0, r2					@; if freq >= -4363
		bge .Lend_rsi_timer0

		strh r0, [r1]
		ldr r1, =TIMER0_DATA
		strh r0, [r1]				@; TIMER0_DATA = divF0 

		b .Lend_rsi_timer0
		.Lelement_not_moved:
			bl desactiva_timer0
		.Lend_rsi_timer0:
		
		pop {r0-r4, pc}

@; update_element(vect_elem[i])
@;	Updates an element position if is it's active, and decrements ii var
@;	Params:
@; 		R0 = @vect_elem[i] (offset)
@;		R1 = vect_elem index (i)
@;  Result:
@; 		R0 = 1 (if element moved), 0 otherwise
update_elment:
	push {r1-r6, lr}
		mov r3, #0					@; element_moved = false 

		ldsh r2, [r0]				@; r4 = vect_elem[i].ii
		cmp r2, #0					@; if(vect_elem[i].ii > 0)	
		ble .Lignore_inactive_elem

		mov r3, #1					@; element_moved = true

		sub r2, #1
		strh r2, [r0]				@; vect_elem[i].ii--;

		ldsh r2, [r0, #ELE_PX]		@; r3 = vect_elem[i].px
		ldsh r4, [r0, #ELE_PY]		@; r4 = vect_elem[i].py
		ldsh r5, [r0, #ELE_VX]		@; r5 = vect_elem[i].vx
		ldsh r6, [r0, #ELE_VY]		@; r6 = vect_elem[i].vy

		adds r2, r5
		adds r4, r6

		strh r2, [r0, #ELE_PX]		
		strh r4, [r0, #ELE_PY]

		mov r0, r1
		mov r1, r2
		mov r2, r4
		bl SPR_moverSprite

		.Lignore_inactive_elem:

		mov r0, r3					@; return element_moved
	pop {r1-r6, pc}


.end
