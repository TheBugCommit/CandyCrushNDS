@;=                                                         	      	=
@;=== candy1_move: rutinas para contar repeticiones y bajar elementos ===
@;=                                                          			=
@;=== Programador tarea 1E: gerard.casass@estudiants.urv.cat		  ===
@;=== Programador tarea 1F: gerard.casass@estudiants.urv.cat		  ===
@;=                                                         	      	=



.include "../include/candy1_incl.i"



@;-- .text. c�digo de las rutinas ---
.text	
		.align 2
		.arm



@;TAREA 1E;
@; cuenta_repeticiones(*matriz,f,c,ori): rutina para contar el n�mero de
@;	repeticiones del elemento situado en la posici�n (f,c) de la matriz, 
@;	visitando las siguientes posiciones seg�n indique el par�metro de
@;	orientaci�n 'ori'.
@;	Restricciones:
@;		* s�lo se tendr�n en cuenta los 3 bits de menor peso de los c�digos
@;			almacenados en las posiciones de la matriz, de modo que se ignorar�n
@;			las marcas de gelatina (+8, +16)
@;		* la primera posici�n tambi�n se tiene en cuenta, de modo que el n�mero
@;			m�nimo de repeticiones ser� 1, es decir, el propio elemento de la
@;			posici�n inicial
@;	Par�metros:
@;		R0 = direcci�n base de la matriz
@;		R1 = fila 'f'
@;		R2 = columna 'c'
@;		R3 = orientaci�n 'ori' (0 -> Este, 1 -> Sur, 2 -> Oeste, 3 -> Norte)
@;	Resultado:
@;		R0 = n�mero de repeticiones detectadas (m�nimo 1)
	.global cuenta_repeticiones
cuenta_repeticiones:
		push {r1-r2, r3-r6, lr}
		
		mov r5, #COLUMNS
		mla r6, r1, r5, r2
		add r4, r0, r6			@;R4 apunta al elemento (f,c) de 'mat'
		ldrb r5, [r4]
		and r5, #7				@;R5 es el valor filtrado (sin marcas de gel.)
		mov r0, #1				@;R0 = número de repeticiones

		cmp r3, #EAST
		beq .Lconrep_east
		cmp r3, #SOUTH
		beq .Lconrep_south
		cmp r3, #WEST
		beq .Lconrep_west
		cmp r3, #NORTH
		beq .Lconrep_north
		b .Lconrep_end
		
		.Lconrep_east:
			add r2, #1

			cmp r2, #COLUMNS
			bhs .Lconrep_end

			add r4, #1
			ldrb r6, [r4]
			and r3, r6, #7		 

			cmp r3, r5			
			addeq r0, #1
			bne .Lconrep_end

			b .Lconrep_east

		.Lconrep_west:
			sub r2, #1

			cmp r2, #0
			blt .Lconrep_end

			sub r4, #1
			ldrb r6, [r4]
			and r3, r6, #7		 

			cmp r3, r5			
			addeq r0, #1
			bne .Lconrep_end

			b .Lconrep_west

		.Lconrep_north:
			sub r1, #1

			cmp r1, #0
			blt .Lconrep_end

			sub r4, #COLUMNS
			ldrb r2, [r4]
			and r3, r2, #7 

			cmp r3, r5			
			addeq r0, #1
			bne .Lconrep_end

			b .Lconrep_north

		.Lconrep_south:
			add r1, #1

			cmp r1, #ROWS
			bhs .Lconrep_end

			add r4, #COLUMNS
			ldrb r2, [r4]
			and r3, r2, #7 

			cmp r3, r5			
			addeq r0, #1
			bne .Lconrep_end

			b .Lconrep_south

		.Lconrep_end:

		pop {r1-r2, r3-r6, pc}



@;TAREA 1F;
@; baja_elementos(*matriz): rutina para bajar elementos hacia las posiciones
@;	vac�as, primero en vertical y despu�s en sentido inclinado; cada llamada a
@;	la funci�n s�lo baja elementos una posici�n y devuelve cierto (1) si se ha
@;	realizado alg�n movimiento, o falso (0) si est� todo quieto.
@;	Restricciones:
@;		* para las casillas vac�as de la primera fila se generar�n nuevos
@;			elementos, invocando la rutina 'mod_random' (ver fichero
@;			"candy1_init.s")
@;	Par�metros:
@;		R0 = direcci�n base de la matriz de juego
@;	Resultado:
@;		R0 = 1 indica se ha realizado alg�n movimiento, de modo que puede que
@;				queden movimientos pendientes. 
	.global baja_elementos
baja_elementos:
		push {r1, r4, lr}
		
		mov r4, r0							@; r4 =  @matrix
		.Lif_vertical_down_shift:
			bl baja_verticales
			cmp r0, #1						@; if(baja_verticales(r4)) return 1;
			beq .Lend_if_vertical_down_shift
		.Lelse_vertical_down_shift:
			bl baja_laterales				
		.Lend_if_vertical_down_shift:

		pop {r1, r4, pc}



@;:::RUTINAS DE SOPORTE:::



@; baja_verticales(mat): rutina para bajar elementos hacia las posiciones vac�as
@;	en vertical; cada llamada a la funci�n s�lo baja elementos una posici�n y
@;	devuelve cierto (1) si se ha realizado alg�n movimiento.
@;	Par�metros:
@;		R4 = direcci�n base de la matriz de juego
@;	Resultado:
@;		R0 = 1 indica que se ha realizado alg�n movimiento. 
baja_verticales:
		push {r1-r3, r5-r11, lr}
		
		mov r7, #0								@; r7 = no movements
		mov r6, #ROWS*COLUMNS - 1				@; offset = ROWS*COLUMNS - 1
		.Lfor_vertical_down_shift:
			ldrb r3, [r4, r6]					@; r3 = matrix[i][j]

			.Lif_void_position:
				mov r0, r3
				bl is_void_element
				cmp r0, #0
				beq .Lend_if_void_position

				bl search_vertical_element
				cmp r0, #255
				beq .Lend_if_void_position
				
				mov r5, r0					@; r5 = offset 1
				bl move_elements
				mov r7, #1					@; r7 = have been movements				
			.Lend_if_void_position:
				
			sub r6, #1							@; offset--
			cmp r6, #COLUMNS - 1				@; offset > COLUMNS - 1
			bhi .Lfor_vertical_down_shift
		.Lend_for_vertical_down_shift:

		mov r11, #SOUTH							@; orientation = SOUTH
		mov r5, #0								@; offset = 0
		.Lfor_first_row:
			mov r8, #0							@; i = 0
			mov r6, r5							@; save offset
			.Lwhile_generete_rand_on_top:
				ldrb r9, [r4, r6]				@; r9 = matrix[i][j]

				.Lif_void_pos_gen_rand:
					mov r0, r9
					bl is_void_element
					cmp r0, #0
					beq .Lelse_if_is_gap

					mov r7, #1					@; r7 = have been movement
					mov r0, #6
					bl mod_random
					add r0, #1
					mov r10, r0					@; copy r0 element code

					mov r1, #-1					@; r1 = row		
					mov r2, r5					
					bl crea_elemento			@; create sprite element, in (-1,col) 
				
					mov r0, #-1
					mov r1, r5
					mov r2, r8
					mov r3, r5
					bl activa_elemento			@; activa_elemento(-1, col, row, col)

					mov r0, r10					@; restore r0 element code
					add r0, r9					@; jelly_code + element_code
					strb r0, [r4, r6]
					b .Lend_while_generete_rand_on_top
				.Lelse_if_is_gap:
					mov r0, r9
					bl is_gap
					cmp r0, #1
					beq .Lend_if_void_pos_gen_rand
				.Lelse_is_solid_or_element:
					b .Lend_while_generete_rand_on_top
				.Lend_if_void_pos_gen_rand:

				mov r0, r6
				mov r1, r11
				bl move_offset_by_orientation	
				mov r6, r0

				add r8, #1						@; i++
				cmp r8, #ROWS					@; i < ROWS
				blo .Lwhile_generete_rand_on_top
			.Lend_while_generete_rand_on_top:

			add r5, #1							@; offset ++ (change column) < COLUMNS
			cmp r5, #COLUMNS
			blo .Lfor_first_row
		.Lend_for_first_row:

		mov r0, r7							@; return if have been movements
		
		pop {r1-r3, r5-r11, pc}



@; baja_laterales(mat): rutina para bajar elementos hacia las posiciones vac�as
@;	en diagonal; cada llamada a la funci�n s�lo baja elementos una posici�n y
@;	devuelve cierto (1) si se ha realizado alg�n movimiento.
@;	Par�metros:
@;		R4 = direcci�n base de la matriz de juego
@;	Resultado:
@;		R0 = 1 indica que se ha realizado alg�n movimiento. 
baja_laterales:
		push {r1-r3, r5-r7, lr}
		
		mov r7, #0								@; r7 = no movements
		mov r6, #ROWS*COLUMNS - 1				@; offset = ROWS*COLUMNS - 1
		.Lfor_side_down_shift:
			ldrb r3, [r4, r6]					@; r3 = matrix[i][j]

			.Lif_void_position_side:
				mov r0, r3
				bl is_void_element
				cmp r0, #0
				beq .Lend_if_void_position_side

				bl search_side_element
				cmp r0, #255
				beq .Lend_if_void_position_side
				
				mov r5, r0					@; r5 = offset 1
				bl move_elements
				mov r7, #1					@; r7 = have been movements				
			.Lend_if_void_position_side:
				
			sub r6, #1							@; offset--
			cmp r6, #COLUMNS - 1				@; offset > COLUMNS - 1
			bhi .Lfor_side_down_shift
		.Lend_for_side_down_shift:

		mov r0, r7							@; return if have been movements
		
		pop {r1-r3, r5-r7, pc}

@; search_vertical_element(@matrix, offset): 
@; looks to see if there are any elements in the column, skipping the
@; possible upper holes (consecutive) until reaching a solid block,
@; an empty position, or overflow the board from above
@;	Params:
@;		R4 = @matrix
@;		R6 = offset
@;	Resultado:
@;		R0 = matrix offset if exists element on column, 255 otherwise 
search_vertical_element: 
	push {r1-r3, r6, lr}

	mov r0, r6					@; r0 = offset
	sub sp, #8
	mov r1, sp					@; @row
	add r2, sp, #4				@; @column
	bl get_row_columun
	ldr r2, [r1]				@; r2 = row					
	add sp, #8					@; clear sp


	.Lwhile_gap:
		cmp r2, #0				@; if(row <= 0)
		movls r0, #255			@; return 255
		bls .Loverflow_board

		mov r0, r6
		mov r1, #NORTH
		bl move_offset_by_orientation	
		mov r6, r0

		sub r2, #1				@; row--

		ldrb r3, [r4, r6]		

		mov r0, r3
		bl is_gap			
		cmp r0, #1
		beq .Lwhile_gap

	mov r0, r3
	bl is_element
	cmp r0, #0	
	moveq r0, #255
	movne r0, r6			@; return offset

	.Loverflow_board:

	pop {r1-r3, r6, pc}

@; search_side_element(@matrix, offset): 
@; It looks in the top-right and top-left corners, 
@; if there are any elements that can be lowered, and returns its offset. 
@; If both can get off, it will be random.
@;	Params:
@;		R4 = @matrix
@;		R6 = offset
@;	Resultado:
@;		R0 = matrix offset if exists element on column, 255 otherwise 
search_side_element:
	push {r1-r3, r6, lr}

	cmp r6, #COLUMNS - 1				@; if(row <= COLUMNS - 1)
	movls r0, #255 
	bls .Linvalid_offset

	mov r0, r6
	mov r1, #NORTH
	bl move_offset_by_orientation	
	mov r6, r0

	mov r0, r6					@; r0 = offset
	sub sp, #8
	mov r1, sp					@; @row
	add r2, sp, #4				@; @column
	bl get_row_columun
	ldr r2, [r1, #4]			@; r2 = column
	add sp, #8					@; clear sp

	mov r3, r6
	cmp r2, #COLUMNS - 1		@;if(column == COLUMNS - 1)
	subeq r3, r6, #1			
	cmp r2, #0					@;if(column == 0)
	addeq r3, r6, #1

	.Lif_is_in_middle:
		cmp r3, r6				@; if(r3 == r6)
		bne .Lelse_is_not_in_middle
		
		add r1, r3, #1			@; r1 = offset upper - right
		sub r3, #1				@; r3 = offset upper - left

		.Lif_both_are_elements:
			ldrb r6, [r4, r1]			
			mov r0, r6
			bl is_element
			cmp r0, #0
			beq .Lelse_if_left_is_element

			ldrb r6, [r4, r3]
			mov r0, r6
			bl is_element
			cmp r0, #0
			beq .Lelse_if_right_is_element

			.Lif_right_or_left:
				mov r2, #2
				bl mod_random
				cmp r0, #1					@; if(mod_random() == 1) right_offset else left_offset
				bne .Lelse_left
				mov r0, r1
				b .Lend_if_right_or_left
			.Lelse_left:
				mov r0, r3
			.Lend_if_right_or_left:

			b .Lend_if_both_are_elements
		.Lelse_if_left_is_element:
			ldrb r6, [r4, r3]
			mov r0, r6
			bl is_element
			cmp r0, #0
			movne r0, r3
			beq .Lelse_no_elemnts
			b .Lend_if_both_are_elements
		.Lelse_if_right_is_element:
			mov r0, r1
			b .Lend_if_both_are_elements
		.Lelse_no_elemnts:
			mov r0, #255
		.Lend_if_both_are_elements:

		b .Lend_if_is_in_middle
	.Lelse_is_not_in_middle:
		ldrb r6, [r4, r3]	
		mov r0, r6
		bl is_element
		cmp r0, #0	
		moveq r0, #255
		movne r0, r3			@; return offset	
	.Lend_if_is_in_middle:

	.Linvalid_offset:

	pop {r1-r3, r6, pc}


@; move_elements(@matrix, offset1, offset2): 
@;  Action to move the element from position offset1 to offset2
@;	Params:
@;		R4 = @matrix
@;		R5 = offset1
@; 		R6 = offset2
move_elements: 
	push {r0-r3, r5-r7, lr}

	ldrb r1, [r4, r5]			@; r1 = matrix[offset1]
	
	mov r0, r1
	bl is_jelly
	strb r0, [r4, r5]			@; store new matrix[offset1] code (0, 8, 16)

	mov r0, r1
	bl is_element				@; r0 = offset1 element code

	ldrb r1, [r4, r6]			@; r1 = matrix[offset2]
	add r1, r0					@; matrix[offset2] + offset1 element code
	strb r1, [r4, r6]			@; store new code to matrix[offset2]


	@; activate element animation
	sub sp, #8
	mov r0, r5					@; r0 = offset 1
	mov r1, sp					@; @row
	add r2, sp, #4				@; @column
	bl get_row_columun
	ldr r7, [r1]				@; r7 = row1			
	ldr r5, [r1, #4]			@; r5 = column1

	mov r0, r6					@; r0 = offset 2
	mov r1, sp					@; @row
	add r2, sp, #4				@; @column
	bl get_row_columun
	ldr r2, [r1]				@; r2 = row2			
	ldr r3, [r1, #4]			@; r3 = column2

	mov r0, r7					@; r0 = row1
	mov r1, r5					@; r1 = column1
	add sp, #8					@; clear sp

	bl activa_elemento

	pop {r0-r3, r5-r7, pc}

.end
